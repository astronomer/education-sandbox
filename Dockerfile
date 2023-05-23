FROM quay.io/astronomer/astro-runtime:8.2.0

ENV AIRFLOW__CORE__ALLOWED_DESERIALIZATION_CLASSES = airflow\.* astro\.*