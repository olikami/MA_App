from rest_framework import serializers

from certificates.models import ApplicationUser, CertificateSigningRequest, Certificate


class ApplicationUserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = ApplicationUser
        fields = [
            "url",
            "first_name",
            "last_name",
        ]


class CertificateSigningRequestSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = CertificateSigningRequest
        fields = ["uuid", "created", "user", "common_name", "csr_string", "status"]
        read_only_fields = ("status",)


class CertificateSerializer(serializers.HyperlinkedModelSerializer):
    csr = serializers.HyperlinkedRelatedField(
        view_name="certificatesigningrequest-detail", read_only=True
    )

    class Meta:
        model = Certificate
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
