from django.contrib import admin

from certificates.models import ApplicationUser, CertificateSigningRequest


@admin.register(ApplicationUser)
class ApplicationUserAdmin(admin.ModelAdmin):
    readonly_fields = ["uuid"]
    list_display = ["first_name", "last_name", "short_uuid", ]


@admin.register(CertificateSigningRequest)
class CertificateSigningRequestAdmin(admin.ModelAdmin):
    list_filter = ["status"]
