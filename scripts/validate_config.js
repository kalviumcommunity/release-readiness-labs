#!/usr/bin/env node
'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { createRequire } = require('node:module');
const { parseAllDocuments } = createRequire(path.resolve(__dirname, '../app/package.json'))('yaml');

const root = path.resolve(__dirname, '..');
const yamlFiles = [
  '.github/workflows/release.yml',
  'deployment/kubernetes/deployment.yaml',
  'deployment/kubernetes/service.yaml',
  'release/approvals.yml',
  'release/deployment-config.yml',
  'release/release-summary.yml',
  'release/rollback.yml',
];
const docs = new Map();
for (const relative of yamlFiles) {
  const file = path.join(root, relative);
  const parsed = parseAllDocuments(fs.readFileSync(file, 'utf8'));
  const errors = parsed.flatMap((document) => document.errors);
  if (errors.length || parsed.length !== 1 || parsed[0].contents === null) {
    throw new Error(`${relative}: ${errors.map((error) => error.message).join('; ') || 'empty or multiple documents'}`);
  }
  docs.set(relative, parsed[0].toJS({ mapAsMap: false }));
  console.log(`Valid YAML: ${relative}`);
}

const version = 'v2.3.0';
const pkg = JSON.parse(fs.readFileSync(path.join(root, 'app/package.json'), 'utf8'));
const release = JSON.parse(fs.readFileSync(path.join(root, 'release/release.json'), 'utf8'));
if (`v${pkg.version}` !== version || release.version !== version || release.applicationVersion !== pkg.version) {
  throw new Error('Release version mismatch across app/package.json and release/release.json');
}
const workflow = docs.get('.github/workflows/release.yml');
const jobs = workflow.jobs;
if (!workflow.on.push.tags.includes(version) || !Object.hasOwn(workflow.on, 'workflow_dispatch')) {
  throw new Error('Workflow must run on the v2.3.0 tag and allow manual dispatch');
}
if (workflow.on.workflow_dispatch.inputs?.deploy_to_production?.default !== false) {
  throw new Error('Manual production deployment must default to false');
}
if (jobs['build-image'].needs !== 'test-and-validate') {
  throw new Error('Image build must depend on test-and-validate');
}
if (JSON.stringify([...jobs['deploy-production'].needs].sort()) !== JSON.stringify(['build-image', 'publish-image', 'test-and-validate'])) {
  throw new Error('Production deployment must depend on successful validation, image build, and publish');
}
if (jobs['publish-image'].needs.length !== 2 || !jobs['publish-image'].needs.includes('build-image') || jobs['publish-image'].permissions.packages !== 'write') {
  throw new Error('Image publishing must be a separate, explicitly permissioned job');
}
if (jobs['deploy-production'].environment.name !== 'production') {
  throw new Error('Production job must reference the protected production environment');
}
const imageBuild = jobs['build-image'].steps.find((step) => step.uses === 'docker/build-push-action@v6');
if (imageBuild?.with?.push !== false || jobs['build-image'].permissions.packages !== undefined) {
  throw new Error('Validation-only image build must not publish and must not have package-write permission');
}
if (!jobs['publish-image'].if?.includes('inputs.deploy_to_production')) {
  throw new Error('Image publishing must require explicit release opt-in');
}
if (!jobs['deploy-production'].if?.includes('inputs.deploy_to_production') || !jobs['deploy-production'].if.includes("github.ref == 'refs/tags/v2.3.0'")) {
  throw new Error('Manual deployment must require explicit opt-in from the v2.3.0 tag');
}
const deploymentConfig = docs.get('release/deployment-config.yml');
if (deploymentConfig.release_version !== version || deploymentConfig.environment !== 'production' || deploymentConfig.cluster_credentials_secret !== 'KUBE_CONFIG') {
  throw new Error('Release deployment configuration is inconsistent');
}
for (const relative of ['deployment/kubernetes/deployment.yaml', 'release/deployment-config.yml', 'deployment/terraform/variables.tf']) {
  const content = fs.readFileSync(path.join(root, relative), 'utf8');
  if (/(?:password|secret[_-]?key)\s*[:=]\s*["']?(?!\$|\{)[^\s"']+/i.test(content)) {
    throw new Error(`Possible hardcoded credential in ${relative}`);
  }
}
console.log('Release version, stage dependencies, environment gate, and secret references are consistent.');
