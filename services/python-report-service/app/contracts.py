from enum import StrEnum


class ReportStatus(StrEnum):
    NEW = "Yeni"
    ASSIGNED = "Ustlenildi"
    RESOLVED = "Cozuldu"


class ReportCategory(StrEnum):
    REPAIR = "Ariza"
    CLEANING = "Temizlik"
    SECURITY = "Guvenlik"
    OTHER = "Diger"
