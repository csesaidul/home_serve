"""Add demo profile media and normalized portfolio items.

Revision ID: 20260919_02
Revises: 20260916_01
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20260919_02"
down_revision: Union[str, Sequence[str], None] = "20260916_01"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("client_profiles", sa.Column("profile_photo", sa.String(500), nullable=True))
    op.add_column("client_profiles", sa.Column("address", sa.String(255), nullable=True))
    op.add_column("provider_profiles", sa.Column("profile_photo", sa.String(500), nullable=True))
    op.add_column("provider_profiles", sa.Column("location", sa.String(255), nullable=True))
    op.add_column("provider_profiles", sa.Column("years_experience", sa.Integer(), nullable=True))
    op.add_column("provider_profiles", sa.Column("job_success_pct", sa.Integer(), nullable=True))
    op.add_column("provider_profiles", sa.Column("response_time", sa.String(50), nullable=True))
    op.add_column("provider_profiles", sa.Column("starting_price", sa.Numeric(10, 2), nullable=True))
    op.create_table(
        "portfolio_items",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("provider_id", sa.Integer(), nullable=False),
        sa.Column("title", sa.String(160), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("image_url", sa.String(500), nullable=False),
        sa.Column("category", sa.String(100), nullable=True),
        sa.Column("completed_at", sa.Date(), nullable=True),
        sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["provider_id"], ["users.id"], name="fk_portfolio_items_provider_id"),
        sa.UniqueConstraint("provider_id", "title", name="uq_portfolio_items_provider_title"),
    )


def downgrade() -> None:
    op.drop_table("portfolio_items")
    for table, column in (
        ("provider_profiles", "starting_price"),
        ("provider_profiles", "response_time"),
        ("provider_profiles", "job_success_pct"),
        ("provider_profiles", "years_experience"),
        ("provider_profiles", "location"),
        ("provider_profiles", "profile_photo"),
        ("client_profiles", "address"),
        ("client_profiles", "profile_photo"),
    ):
        op.drop_column(table, column)