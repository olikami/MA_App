from rest_framework import serializers

from certificates.models import ApplicationUser


class ApplicationUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = ApplicationUser
        fields = ["url", "first_name", "last_name"]
