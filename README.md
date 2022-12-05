# metrics-report
Scrape drupal and dataverse data, generate report of metrics

This RMarkdown document utilizes drupal and dataverse data to generate a usage report. It is heavily tailored to the QDR environment, but the dataverse API interface in particular should be reusable.

# Configuration

This repository has three secrets that are used for configuration:

- GH_EXTERNAL_REPO: The name of the external (private) repository where non-public information is kept. In this case, it is exports of Drupal usage data. This repository is also used to deposit the final product (the PDF generated from the Rmd file).
- GH_EXTERNAL_TOKEN: A Github token that allows access to the GH_EXTERNAL_REPO. Currently, this is set as a Personal Access Token (classic). In the future, it would probably be preferable to change this to a repo-limited token that is currently in beta stage. This token requires only *repo* scope.
- DATAVERSE_TOKEN: A token to gain access to the dataverse instance. This should be an admin-level token (i.e. *not* a regular user's token) in order to capture statistics from all the unpublished projects.

# Usage

This document is compiled through Github Actions. It is triggered manually, with a workflow_dispatch action.

The final product, a PDF, is uploaded to an external github repository, specified with GH_EXTERNAL_REPO. This is because there is potentially private information contained within the document.
