from django.db import models


class CertificateType(models.IntegerChoices):
    USER = 0
    MODERATOR = 1
    OFFICIAL = 2
