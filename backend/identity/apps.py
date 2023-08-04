from django.apps import AppConfig


class CertificatesConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "identity"

    def ready(self):
        from . import signals
