# Generated by Django 4.2.3 on 2023-07-13 18:32

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("certificates", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="certificatesigningrequest",
            name="csr_string",
            field=models.TextField(),
        ),
    ]