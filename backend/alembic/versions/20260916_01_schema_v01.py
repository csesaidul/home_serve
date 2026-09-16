"""Create the HomeServe MVP v0.1 core schema.

Revision ID: 20260916_01
Revises:
Create Date: 2026-09-16
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "20260916_01"
down_revision: Union[str, Sequence[str], None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(120), nullable=False),
        sa.Column("gender", sa.String(30), nullable=True),
        sa.Column("phone", sa.String(30), nullable=False),
        sa.Column("phone_verified", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("is_admin", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("last_known_lat", sa.Float(), nullable=True),
        sa.Column("last_known_lng", sa.Float(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("phone", name="uq_users_phone"),
    )

    op.create_table(
        "client_profiles",
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("verified", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("verified_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("user_id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name="fk_client_profiles_user_id"),
    )

    op.create_table(
        "provider_profiles",
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("bio", sa.Text(), nullable=True),
        sa.Column("skills", sa.Text(), nullable=True),
        sa.Column("categories", sa.Text(), nullable=True),
        sa.Column("portfolio", sa.Text(), nullable=True),
        sa.Column("status", sa.String(20), nullable=False, server_default="pending"),
        sa.Column("verified", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("rating_avg", sa.Numeric(3, 2), nullable=False, server_default="0.00"),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("user_id"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name="fk_provider_profiles_user_id"),
    )

    op.create_table(
        "service_categories",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("icon", sa.String(255), nullable=True),
        sa.Column("base_price", sa.Numeric(10, 2), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name", name="uq_service_categories_name"),
    )

    op.create_table(
        "bookings",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("client_id", sa.Integer(), nullable=False),
        sa.Column("provider_id", sa.Integer(), nullable=False),
        sa.Column("category_id", sa.Integer(), nullable=False),
        sa.Column("status", sa.String(20), nullable=False, server_default="requested"),
        sa.Column("scheduled_at", sa.DateTime(), nullable=False),
        sa.Column("address", sa.String(500), nullable=False),
        sa.Column("price_estimate", sa.Numeric(10, 2), nullable=True),
        sa.Column("payment_status", sa.String(20), nullable=False, server_default="unpaid"),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["client_id"], ["users.id"], name="fk_bookings_client_id"),
        sa.ForeignKeyConstraint(["provider_id"], ["users.id"], name="fk_bookings_provider_id"),
        sa.ForeignKeyConstraint(["category_id"], ["service_categories.id"], name="fk_bookings_category_id"),
    )

    op.create_table(
        "reviews",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("booking_id", sa.Integer(), nullable=False),
        sa.Column("rating", sa.Integer(), nullable=False),
        sa.Column("comment", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(), nullable=False, server_default=sa.func.now()),
        sa.PrimaryKeyConstraint("id"),
        sa.ForeignKeyConstraint(["booking_id"], ["bookings.id"], name="fk_reviews_booking_id"),
        sa.UniqueConstraint("booking_id", name="uq_reviews_booking_id"),
        sa.CheckConstraint("rating BETWEEN 1 AND 5", name="ck_reviews_rating_range"),
    )


def downgrade() -> None:
    op.drop_table("reviews")
    op.drop_table("bookings")
    op.drop_table("service_categories")
    op.drop_table("provider_profiles")
    op.drop_table("client_profiles")
    op.drop_table("users")
