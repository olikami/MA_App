from django.contrib import admin

from identity.models import (
    ApplicationUser,
    CertificateSigningRequest,
    EndUserCertificate,
    IntermediateCertificate,
)


@admin.register(ApplicationUser)
class ApplicationUserAdmin(admin.ModelAdmin):
    readonly_fields = ["uuid"]
    list_display = [
        "first_name",
        "last_name",
        "short_uuid",
    ]


@admin.register(IntermediateCertificate)
class IntermediateCertificateAdmin(admin.ModelAdmin):
    list_display = ["id", "active", "type", "common_name"]
    list_filter = ["active", "type"]
    readonly_fields = ["common_name"]


@admin.register(CertificateSigningRequest)
class CertificateSigningRequestAdmin(admin.ModelAdmin):
    list_display = ["user", "created"]
    list_filter = ["status"]
    readonly_fields = ["common_name"]


@admin.register(EndUserCertificate)
class CertificateAdmin(admin.ModelAdmin):
    list_display = ["user", "created", "subject"]
    readonly_fields = ["certificate_string", "subject", "csr", "user", "created"]
