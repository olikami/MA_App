from rest_framework import serializers

from identity.models import (
    ApplicationUser,
    CertificateSigningRequest,
    EndUserCertificate,
)


class ApplicationUserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = ApplicationUser
        fields = [
            "url",
            "first_name",
            "last_name",
        ]


class CertificateSigningRequestSerializer(serializers.HyperlinkedModelSerializer):
    certificate = serializers.HyperlinkedRelatedField(
        view_name="endusercertificate-detail", read_only=True
    )

    class Meta:
        model = CertificateSigningRequest
        fields = [
            "uuid",
            "url",
            "created",
            "user",
            "common_name",
            "csr_string",
            "status",
            "certificate",
        ]
        read_only_fields = ("status",)


class CertificateSerializer(serializers.HyperlinkedModelSerializer):
    csr = serializers.HyperlinkedRelatedField(
        view_name="certificatesigningrequest-detail", read_only=True
    )

    class Meta:
        model = EndUserCertificate
        fields = [
            "url",
            "csr",
            "created",
            "user",
            "certificate_string",
        ]
        read_only_fields = [
            "csr",
            "created",
            "user",
            "certificate_string",
        ]
