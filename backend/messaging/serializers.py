from rest_framework import serializers
from .models import Location, Message


class SimpleMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = ["id", "content", "sent", "signature", "certificate"]


class LocationSerializer(serializers.ModelSerializer):
    messages = SimpleMessageSerializer(many=True, read_only=True)

    class Meta:
        model = Location
        fields = ["url", "postcode", "messages"]


class MessageSerializer(serializers.ModelSerializer):
    location = serializers.PrimaryKeyRelatedField(
        many=False, queryset=Location.objects.all()
    )

    class Meta:
        model = Message
        fields = ["id", "content", "sent", "signature", "certificate", "location"]


class OfficialMessageSerializer(serializers.ModelSerializer):
    locations = serializers.PrimaryKeyRelatedField(
        many=True, queryset=Location.objects.all()
    )

    class Meta:
        model = Message
        fields = ["id", "content", "sent", "signature", "certificate", "locations"]
