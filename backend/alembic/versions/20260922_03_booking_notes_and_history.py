"""Add booking notes and client history lookup support.

Revision ID: 20260922_03
Revises: 20260919_02
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20260922_03"
down_revision: Union[str, Sequence[str], None] = "20260919_02"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "bookings",
        sa.Column("customer_notes", sa.String(1000), nullable=True),
    )
    op.create_index(
        "ix_bookings_client_scheduled_at",
        "bookings",
        ["client_id", "scheduled_at"],
    )


def downgrade() -> None:
    op.drop_index("ix_bookings_client_scheduled_at", table_name="bookings")
    op.drop_column("bookings", "customer_notes")
