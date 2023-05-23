Example DAGs for Apache Airflow 2.6
===================================

This repository contains example DAGs showing features released in Apache Airflow 2.6. 

Aside from Apache Airflow this project uses [DuckDB](https://duckdb.org/) (via the [Airflow DuckDB provider](https://github.com/astronomer/airflow-provider-duckdb)), the [Airflow Slack provider](https://registry.astronomer.io/providers/apache-airflow-providers-slack/versions/7.2.0) and the [Astro Python SDK](https://astro-sdk-python.readthedocs.io/en/stable/index.html).

# How to use this repository

This section explains how to run this repository with Airflow. Note that for some DAGs you will need to define extra connections (AWS and/or Slack). See the [Manage Connections in Apache Airflow](https://docs.astronomer.io/learn/connections) guide for instructions. DAGs with the tag `toy` work without any additional connections or tools.

## Option 1: Use GitHub Codespaces

Run this Airflow project without installing anything locally.

1. Fork this repository.
2. Create a new GitHub codespaces project on your fork. Make sure it uses at least 4 cores!
3. After creating the codespaces project the Astro CLI will automatically start up all necessary Airflow components. This can take a few minutes. 
4. Once the Airflow project has started, access the Airflow UI by clicking on the **Ports** tab and opening the forward URL for port 8080.

## Option 2: Use the Astro CLI

Download the [Astro CLI](https://docs.astronomer.io/astro/cli/install-cli) to run Airflow locally in Docker. `astro` is the only package you will need to install.

1. Run `git clone https://github.com/astronomer/2-6-example-dags.git` on your computer to create a local clone of this repository.
2. Install the Astro CLI by following the steps in the [Astro CLI documentation](https://docs.astronomer.io/astro/cli/install-cli). Docker Desktop/Docker Engine is a prerequisite, but you don't need in-depth Docker knowledge to run Airflow with the Astro CLI.
3. Run `astro dev start` in your cloned repository.
4. After your Astro project has started. View the Airflow UI at `localhost:8080`.

# DAGs

The following sections list the DAGs shown sorted by the feature that they showcase. You can filter DAGs in the UI by their `tags`.

## ContinuousTimetable

Tag: `ContinuousTimetable`

### Toy example

The `continuous_toy` DAG contains one task which sleeps for a random number of seconds, after completion of the task the DAG will reschedule itself automatically, irrespective of whether it was successful or not. No connections need to be created in order to use this DAG.

### S3 example

The use case/S3 example for the continuous timetable is a pipeline which waits for a file to drop in S3 using the `S3KeySensorAsync`. Once the file lands it is moved to a different folder and a second DAG is kicked off via a [Dataset](https://docs.astronomer.io/learn/airflow-datasets) running a transformation in SQL and an analysis in Pandas using the Astro Python SDK.

To use this example you will need to define a [connection](https://docs.astronomer.io/learn/connections) to your AWS account with the connection ID `aws_conn`. You will also need at least one S3 bucket. Provide its name to all the DAGs of the use case as `MY_BUCKET_NAME`. The connection to DuckDB is automatically configured from the `airflow_settings.yaml` file.

- `load_file_to_S3`: a helper DAG to easily load the `my_log.csv` file from the include folder to S3.
- `continuous_S3`: the DAG sensing for the file to land and moving it from one to another folder in the S3 bucket.
- `downstream_S3`: the downstream DAG running transformations on the S3 file.

Note: The `continuous_S3` DAG uses dynamic task mapping, learn more in the [Create dynamic Airflow tasks](https://docs.astronomer.io/learn/dynamic-tasks) guide.

## Notifier

Tag: `Notifier`

### Toy example

The toy example is a DAG with 4 tasks, 2 of which will always fail. It shows callbacks being used at the DAG-level, in default_args and at the task level.

### Slack example

Example showing how to use the SlackNotifier. Needs a Slack connection with the connection ID `slack_conn`  and a Slack API Token for a Slack bot (starts with 'xoxb-...'). The message posted includes [Jinja templated information](https://docs.astronomer.io/learn/templating). You may need to adjust the `SLACK_CHANNEL` variable to be set to a channel you bot has access to.

### S3 example

DAG that loads a copy of the `my_log.csv` file from the `include` folder to an S3 bucket (`MY_BUCKET_NAME`) using the connection supplied as `aws_conn` and the Astro Python SDK. The DAG then runs a transformation and an analysis which succeeds if `THIS_DAG_SHOULD_SUCCEED=True` and fails if `THIS_DAG_SHOULD_SUCCEED=False`.

At the DAG level both a `on_success_callback` and `on_failure_callback` is set using the custom notifier `MyS3Notifier` which is stored in `include/aws_notifier.py`. By default the notification text file is written into the same S3 bucket (`MY_BUCKET_NAME`) in a different folder (`NOTIFICATION_FOLDER`).

## Triggerer logging and deferrable TriggerDagRunOperator

Toy example showing the trigger logs in the Airflow task logs, as well as a deferrable TriggerDagRunOperator (set via the `deferrable` parameter).

The `deferrable_triggerdagrunoperator_toy` DAG contains the deferrable TriggerDagRunOperator which will kick off the `downstream_trigger_dagrun` DAG and wait for its completion after the amount of seconds provided in the dag run configuration via the `conf` parameter. 

The trigger logs are shown in the task logs of the TriggerDagRunOperator and look similar to:

```text
[2023-04-25, 13:38:40 UTC] {triggerer_job_runner.py:615} INFO - Trigger deferrable_triggerdagrunoperator_toy/manual__2023-04-25T13:38:02.457058+00:00/trigger_dagrun/-1/1 (ID 111) fired: TriggerEvent<('airflow.triggers.external_task.DagStateTrigger', {'dag_id': 'downstream_trigger_dagrun', 'states': ['success', 'failed'], 'execution_dates': [DateTime(2023, 4, 25, 13, 38, 13, 469267, tzinfo=Timezone('UTC'))], 'poll_interval': 5})>
```

# Other DAGs

- `json_yaml_macros_toy`: Shows how to use JSON and YAML input in Jinja templating.
- `UI_features_toy`: DAG with a complex structure using nested task group to showcase new UI features.
- `retry_example`: is a DAG showing different retries configurations. 2.6 introduced the Airflow config `core.max_task_retry_delay`.
- `max_active_tis_per_dagrun`: DAG showing the difference between `max_active_tis_per_dagrun` and `max_active_tis_per_dag` in a simple mapping example. `max_active_tis_per_dag`: is new in Airflow 2.6 and allows you to restrict how many mapped task instances of a task can run at the same time for the same DAG run.
- `pandas_xcom`: Toy DAG passing a pandas.DataFrame object via XCom, which was added to standard XCom via pyarrow serialization in 2.6.
- `trigger_with_params`: DAG to trigger w/config to show new UI features.

# Useful links:

- [DAG scheduling and timetables in Airflow](https://docs.astronomer.io/learn/scheduling-in-airflow) guide.
- [Manage Airflow DAG notifications](https://docs.astronomer.io/learn/error-notifications-in-airflow) guide.
- [Write a DAG with the Astro Python SDK](https://docs.astronomer.io/learn/astro-python-sdk) tutorial.
- [Astro Python SDK](https://astro-sdk-python.readthedocs.io/en/stable/index.html) documentation.

# Project Structure

This repository contains the following files and folders:

- `.astro`: files necessary for Astro CLI commands.
- `.devcontainer`: the GH codespaces configuration.
-  `dags`: all DAGs in your Airflow environment. Files in this folder will be parsed by the Airflow scheduler when looking for DAGs to add to your environment. You can add your own dagfiles in this folder.
- `include`: supporting files that will be included in the Airflow environment.
    - `aws_notifier.py`: a module containing a custom Notifier class.
    - `my_log.csv`: a toy dataset.
- `plugins`: folder to place Airflow plugins. Empty.
- `tests`: folder to place pytests running on DAGs in the Airflow instance. Contains default tests.
- `.dockerignore`: list of files to ignore for Docker.
- `.gitignore`: list of files to ignore for git. NOTE that `airflow_settings.yaml` is not ignored in this project.
- `airflow_settings.yaml`: contains the connection to DuckDB used in the project.
- `Dockerfile`: the Dockerfile using the Astro CLI.
- `packages.txt`: system-level packages to be installed in the Airflow environment upon building of the Dockerimage.
- `README.md`: this Readme.
- `requirements.txt`: python packages to be installed to be used by DAGs upon building of the Dockerimage.