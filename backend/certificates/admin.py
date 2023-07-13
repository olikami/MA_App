from django.contrib import admin

from certificates.models import ApplicationUser, CertificateSigningRequest, Certificate


@admin.register(ApplicationUser)
class ApplicationUserAdmin(admin.ModelAdmin):
    readonly_fields = ["uuid"]
    list_display = [
        "first_name",
        "last_name",
        "short_uuid",
    ]


@admin.register(CertificateSigningRequest)
class CertificateSigningRequestAdmin(admin.ModelAdmin):
    list_display = ["user", "created"]
    list_filter = ["status"]
    readonly_fields = ["common_name"]


@admin.register(Certificate)
class CertificateAdmin(admin.ModelAdmin):
    list_display = ["user", "created"]
