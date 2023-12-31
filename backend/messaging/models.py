import uuid

from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models

from identity.models import ApplicationUser


class Location(models.Model):
    postcode = models.PositiveIntegerField(
        primary_key=True, validators=[MinValueValidator(1000), MaxValueValidator(9999)]
    )

    def __str__(self):
        return str(self.postcode)

    def messages(self):
        return Message.objects.filter(location=self).order_by("-sent")[:100]


class Message(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    content = models.TextField()
    sent = models.DateTimeField(auto_now_add=True)
    signature = models.CharField(max_length=1024)
    certificate = models.TextField()
    location = models.ForeignKey(
        Location,
        on_delete=models.CASCADE,
    )

    def __str__(self):
        return f"Message at {self.sent.strftime('%Y-%m-%d %H:%M:%S')}"


class OfficialMessage(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4)
    content = models.TextField()
    sent = models.DateTimeField(auto_now_add=True)
    signature = models.CharField(max_length=1024)
    certificate = models.TextField()
    locations = models.ManyToManyField(Location)

    def __str__(self):
        return f"Official at {self.sent.strftime('%Y-%m-%d %H:%M:%S')}"
