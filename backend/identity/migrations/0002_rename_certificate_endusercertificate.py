# Generated by Django 4.2.4 on 2023-08-04 14:21

from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("identity", "0001_initial"),
    ]

    operations = [
        migrations.RenameModel(
            old_name="Certificate",
            new_name="EndUserCertificate",
        ),
    ]
