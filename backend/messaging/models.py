from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models


class Location(models.Model):
    postcode = models.PositiveIntegerField(
        primary_key=True, validators=[MinValueValidator(1000), MaxValueValidator(9999)]
    )

    def __str__(self):
        return str(self.postcode)
