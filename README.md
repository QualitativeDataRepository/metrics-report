# metrics-report
Scrape drupal and dataverse data, generate report of metrics

This RMarkdown document utilizes drupal and dataverse data to generate a usage report. It is heavily tailored to the QDR environment, but the dataverse API interface in particular should be reusable.

# Configuration

This repository has three secrets that are used for configuration:

- EXTERNAL_GH_FOLDER: The name of the external (private) repository where non-public information is kept. In this case, it is exports of Drupal usage data. This repository is also used to deposit the final product (the PDF generated from the Rmd file).
- EXTERNAL_GH_TOKEN: A Github token that allows access to the GH_EXTERNAL_REPO. Currently, this is set as a Personal Access Token (classic). In the future, it would probably be preferable to change this to a repo-limited token that is currently in beta stage. This token requires only *repo* scope.
- DATAVERSE_TOKEN: A token to gain access to the dataverse instance. This should be an admin-level token (i.e. *not* a regular user's token) in order to capture statistics from all the unpublished projects.

# Usage

This document is compiled through Github Actions. It is triggered manually, with a workflow_dispatch action.

There are three paramaters one can set at run-time. These options are visible when triggering the workflow.

- Prospective institutional member: this is a string variable that is added to the existing list of institutional members. This should be the name of a university, for example. You can also specify multiple prospective members in a comma-delimited string, e.g. "Georgetown,George Mason"
- beginning/ending dates: these delimit a set of statistics if one is interested in a certain period (for example, the last two years). It does not limit the entire set of statistics (totals are still listed), but rather highlights a certain time period. These dates are specified in YYYY-MM-DD format.

The final product, a PDF, is uploaded to an external github repository, specified with GH_EXTERNAL_REPO. This is because there is potentially private information contained within the document.
