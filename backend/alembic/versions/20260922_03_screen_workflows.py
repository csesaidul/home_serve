"""Add persistence used by client and provider screen workflows."""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20260922_03"
down_revision: Union[str, Sequence[str], None] = "20260919_02"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("email", sa.String(255), nullable=True))
    op.add_column("users", sa.Column("sms_notifications_enabled", sa.Boolean(), nullable=False, server_default=sa.true()))
    op.add_column("provider_profiles", sa.Column("id_verification_status", sa.String(30), nullable=False, server_default="not_started"))
    op.add_column("provider_profiles", sa.Column("trade_certificate_url", sa.String(500), nullable=True))
    op.add_column("provider_profiles", sa.Column("submitted_at", sa.DateTime(), nullable=True))
    op.add_column("provider_profiles", sa.Column("rejection_reason", sa.String(500), nullable=True))
    op.create_table(
        "saved_addresses",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("label", sa.String(80), nullable=False),
        sa.Column("address", sa.String(500), nullable=False),
        sa.Column("is_default", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name="fk_saved_addresses_user_id"),
    )


def downgrade() -> None:
    op.drop_table("saved_addresses")
    for table, column in (("provider_profiles", "rejection_reason"), ("provider_profiles", "submitted_at"), ("provider_profiles", "trade_certificate_url"), ("provider_profiles", "id_verification_status"), ("users", "sms_notifications_enabled"), ("users", "email")):
        op.drop_column(table, column)