from rest_framework import serializers
from .models import Location, Message


class SimpleMessageSerializer(serializers.ModelSerializer):
    author = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Message
        fields = ["id", "content", "sent", "signature", "author"]


class LocationSerializer(serializers.ModelSerializer):
    messages = SimpleMessageSerializer(many=True, read_only=True)

    class Meta:
        model = Location
        fields = ["url", "postcode", "messages"]


class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = [
            "id",
            "content",
            "sent",
            "signature",
            "author",
        ]