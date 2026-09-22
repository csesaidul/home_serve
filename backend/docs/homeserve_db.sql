-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 22, 2026 at 03:46 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `homeserve_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `alembic_version`
--

CREATE TABLE `alembic_version` (
  `version_num` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alembic_version`
--

INSERT INTO `alembic_version` (`version_num`) VALUES
('20260919_02');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'requested',
  `scheduled_at` datetime NOT NULL,
  `address` varchar(500) NOT NULL,
  `price_estimate` decimal(10,2) DEFAULT NULL,
  `payment_status` varchar(20) NOT NULL DEFAULT 'unpaid',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `client_id`, `provider_id`, `category_id`, `status`, `scheduled_at`, `address`, `price_estimate`, `payment_status`, `created_at`) VALUES
(401, 101, 201, 10, 'completed', '2026-09-15 14:30:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 22:08:24'),
(402, 102, 201, 10, 'completed', '2026-09-12 11:00:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 22:08:24'),
(403, 103, 201, 10, 'completed', '2026-09-08 16:15:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 22:08:24'),
(404, 101, 202, 10, 'completed', '2026-09-10 13:00:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 22:08:24'),
(405, 102, 203, 12, 'completed', '2026-09-06 10:45:00', 'Dhaka, Bangladesh', 900.00, 'paid', '2026-09-19 22:08:24'),
(406, 103, 204, 10, 'completed', '2026-09-04 15:30:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 22:08:24'),
(501, 101, 201, 10, 'completed', '2026-09-15 14:30:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 23:20:16'),
(502, 102, 201, 10, 'completed', '2026-09-12 11:00:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 23:20:16'),
(503, 103, 201, 10, 'completed', '2026-09-08 16:15:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 23:20:16'),
(504, 101, 202, 10, 'completed', '2026-09-10 13:00:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 23:20:16'),
(505, 102, 203, 12, 'completed', '2026-09-06 10:45:00', 'Dhaka, Bangladesh', 900.00, 'paid', '2026-09-19 23:20:16'),
(506, 103, 204, 10, 'completed', '2026-09-04 15:30:00', 'Dhaka, Bangladesh', 800.00, 'paid', '2026-09-19 23:20:16');

-- --------------------------------------------------------

--
-- Table structure for table `client_profiles`
--

CREATE TABLE `client_profiles` (
  `user_id` int(11) NOT NULL,
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  `verified_at` datetime DEFAULT NULL,
  `profile_photo` varchar(500) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `client_profiles`
--

INSERT INTO `client_profiles` (`user_id`, `verified`, `verified_at`, `profile_photo`, `address`) VALUES
(1, 0, NULL, NULL, NULL),
(2, 0, NULL, NULL, NULL),
(6, 0, NULL, NULL, NULL),
(7, 0, NULL, NULL, NULL),
(101, 1, NULL, '/assets/profile_photos/person 13.png', 'Dhanmondi, Dhaka'),
(102, 1, NULL, '/assets/profile_photos/person 14.png', 'Gulshan, Dhaka'),
(103, 1, NULL, '/assets/profile_photos/person 12.png', 'Uttara, Dhaka');

-- --------------------------------------------------------

--
-- Table structure for table `portfolio_items`
--

CREATE TABLE `portfolio_items` (
  `id` int(11) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `title` varchar(160) NOT NULL,
  `description` text DEFAULT NULL,
  `image_url` varchar(500) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `completed_at` date DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `portfolio_items`
--

INSERT INTO `portfolio_items` (`id`, `provider_id`, `title`, `description`, `image_url`, `category`, `completed_at`, `sort_order`) VALUES
(1, 201, 'Main Distribution Board & IPS Synchronization', 'Re-routed 16-way Schneider distribution board and synchronized 1.5kVA hybrid IPS line.', '/assets/profile_photos/person 5.png', 'Electrical', '2026-09-12', 0),
(2, 202, 'Industrial Wiring and DB Box', 'Completed a safe industrial wiring upgrade with labelled circuits and short-circuit protection.', '/assets/profile_photos/person 6.png', 'Electrical', '2026-08-27', 0),
(3, 203, 'Home Appliance Safety Check', 'Inspected kitchen appliances, switchboard connections and geyser safety controls.', '/assets/profile_photos/person 7.png', 'Appliance Repair', '2026-08-18', 0),
(4, 204, 'Smart Home Lighting Setup', 'Installed connected switches, dimmable lights and a clean ceiling-fan wiring layout.', '/assets/profile_photos/person 8.png', 'Smart Home', '2026-07-30', 0),
(5, 205, 'Kitchen Appliance Repair', 'Diagnosed and repaired a built-in appliance with a full post-service safety test.', '/assets/profile_photos/person 9.png', 'Appliance Repair', '2026-07-22', 0),
(6, 206, 'Move-in Deep Clean', 'Prepared a two-bedroom home for move-in with kitchen, bathroom and floor detailing.', '/assets/profile_photos/person 10.png', 'Cleaning', '2026-08-10', 0);

-- --------------------------------------------------------

--
-- Table structure for table `provider_profiles`
--

CREATE TABLE `provider_profiles` (
  `user_id` int(11) NOT NULL,
  `bio` text DEFAULT NULL,
  `skills` text DEFAULT NULL,
  `categories` text DEFAULT NULL,
  `portfolio` text DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'pending',
  `verified` tinyint(1) NOT NULL DEFAULT 0,
  `rating_avg` decimal(3,2) NOT NULL DEFAULT 0.00,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `profile_photo` varchar(500) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `years_experience` int(11) DEFAULT NULL,
  `job_success_pct` int(11) DEFAULT NULL,
  `response_time` varchar(50) DEFAULT NULL,
  `starting_price` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `provider_profiles`
--

INSERT INTO `provider_profiles` (`user_id`, `bio`, `skills`, `categories`, `portfolio`, `status`, `verified`, `rating_avg`, `created_at`, `profile_photo`, `location`, `years_experience`, `job_success_pct`, `response_time`, `starting_price`) VALUES
(201, 'Verified electrician specialist serving homes across Dhaka.', 'Electrician', 'Electrician', NULL, 'approved', 1, 4.90, '2026-09-19 21:59:11', '/assets/profile_photos/person 5.png', 'Dhanmondi, Dhaka', 5, 98, '15-30 min', 800.00),
(202, 'Verified electrician specialist serving homes across Dhaka.', 'Electrician, Plumber', 'Electrician, Plumber', NULL, 'approved', 1, 4.95, '2026-09-19 21:59:11', '/assets/profile_photos/person 6.png', 'Mohammadpur, Dhaka', 5, 98, '20-40 min', 700.00),
(203, 'Verified electrician specialist serving homes across Dhaka.', 'Electrician, Appliance Repair', 'Electrician, Appliance Repair', NULL, 'approved', 1, 4.80, '2026-09-19 21:59:11', '/assets/profile_photos/person 7.png', 'Banani, Dhaka', 5, 96, '30-45 min', 650.00),
(204, 'Verified electrician specialist serving homes across Dhaka.', 'Electrician, Smart Home', 'Electrician, Smart Home', NULL, 'approved', 1, 4.70, '2026-09-19 21:59:11', '/assets/profile_photos/person 8.png', 'Mirpur, Dhaka', 5, 96, 'Tomorrow 10 AM', 600.00),
(205, 'Verified appliance repair specialist serving homes across Dhaka.', 'Appliance Repair', 'Appliance Repair', NULL, 'approved', 1, 4.85, '2026-09-19 21:59:11', '/assets/profile_photos/person 9.png', 'Gulshan, Dhaka', 5, 98, '25-40 min', 900.00),
(206, 'Verified cleaning specialist serving homes across Dhaka.', 'Cleaning', 'Cleaning', NULL, 'approved', 1, 4.88, '2026-09-19 21:59:11', '/assets/profile_photos/person 10.png', 'Uttara, Dhaka', 5, 98, '20-35 min', 500.00),
(207, 'Verified plumber specialist serving homes across Dhaka.', 'Plumber', 'Plumber', NULL, 'approved', 1, 4.76, '2026-09-19 21:59:11', '/assets/profile_photos/person 11.png', 'Bashundhara, Dhaka', 5, 96, '40-60 min', 550.00),
(208, 'Verified painting specialist serving homes across Dhaka.', 'Painting', 'Painting', NULL, 'approved', 1, 4.82, '2026-09-19 21:59:11', '/assets/profile_photos/person 12.png', 'Lalmatia, Dhaka', 5, 96, 'Tomorrow 9 AM', 750.00),
(209, 'Verified hvac repair specialist serving homes across Dhaka.', 'HVAC Repair', 'HVAC Repair', NULL, 'approved', 1, 4.91, '2026-09-19 21:59:11', '/assets/profile_photos/person 13.png', 'Tejgaon, Dhaka', 5, 98, '30-45 min', 1000.00),
(210, 'Verified carpentry specialist serving homes across Dhaka.', 'Carpentry', 'Carpentry', NULL, 'approved', 1, 4.79, '2026-09-19 21:59:11', '/assets/profile_photos/person 14.png', 'Badda, Dhaka', 5, 98, '45-60 min', 850.00);

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL,
  `booking_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `booking_id`, `rating`, `comment`, `created_at`) VALUES
(401, 401, 5, 'Rahul arrived within 25 minutes and fixed our tripped master circuit cleanly. Very polite and professional.', '2026-09-15 14:30:00'),
(402, 402, 5, 'Excellent DB breaker fix. He explained the load balancing issue clearly and completed the work safely.', '2026-09-12 11:00:00'),
(403, 403, 4, 'Good service and careful wiring work. The technician also tested every circuit before leaving.', '2026-09-08 16:15:00'),
(404, 404, 5, 'Industrial wiring was completed on time with neat labels and a clear handover.', '2026-09-10 13:00:00'),
(405, 405, 5, 'Quick appliance diagnosis and a thorough safety check. Would book again.', '2026-09-06 10:45:00'),
(406, 406, 4, 'Smart lighting setup looks great and the wiring was kept very tidy.', '2026-09-04 15:30:00'),
(501, 501, 5, 'Rahul arrived within 25 minutes and fixed our tripped master circuit cleanly. Very polite and professional.', '2026-09-15 14:30:00'),
(502, 502, 5, 'Excellent DB breaker fix. He explained the load balancing issue clearly and completed the work safely.', '2026-09-12 11:00:00'),
(503, 503, 4, 'Good service and careful wiring work. The technician also tested every circuit before leaving.', '2026-09-08 16:15:00'),
(504, 504, 5, 'Industrial wiring was completed on time with neat labels and a clear handover.', '2026-09-10 13:00:00'),
(505, 505, 5, 'Quick appliance diagnosis and a thorough safety check. Would book again.', '2026-09-06 10:45:00'),
(506, 506, 4, 'Smart lighting setup looks great and the wiring was kept very tidy.', '2026-09-04 15:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `service_categories`
--

CREATE TABLE `service_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `base_price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `service_categories`
--

INSERT INTO `service_categories` (`id`, `name`, `icon`, `base_price`) VALUES
(1, 'Snow Removal', '/static/icons/snow-removal.png', 75.00),
(2, 'Handyman', '/static/icons/handyman.png', 100.00),
(3, 'Cleaning', '/assets/category_icons/cleaning.png', 500.00),
(4, 'Electrical', '/static/icons/electrical.png', 120.00),
(5, 'Plumbing', '/static/icons/plumbing.png', 150.00),
(6, 'Tutoring', '/static/icons/tutoring.png', 50.00),
(7, 'test', '/static/icons/test.png', 250.00),
(8, 'test2', '/static/icons/test.png', 250.00),
(9, 'test4', '/static/icons/test.png', 250.00),
(10, 'Electrician', '/assets/category_icons/electrician.png', 800.00),
(11, 'Plumber', '/assets/category_icons/plumber.png', 700.00),
(12, 'Appliance Repair', '/assets/category_icons/ac_repair.png', 900.00),
(14, 'Painting', '/assets/category_icons/carpenter.png', 750.00),
(15, 'Carpentry', '/assets/category_icons/carpenter.png', 850.00);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `gender` varchar(30) DEFAULT NULL,
  `phone` varchar(30) NOT NULL,
  `phone_verified` tinyint(1) NOT NULL DEFAULT 0,
  `password_hash` varchar(255) NOT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT 0,
  `last_known_lat` float DEFAULT NULL,
  `last_known_lng` float DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `gender`, `phone`, `phone_verified`, `password_hash`, `is_admin`, `last_known_lat`, `last_known_lng`, `created_at`) VALUES
(1, 'Rahim Uddin', 'male', '01712345678', 1, '$2b$12$jp43GenJEPRYYPE00Ne/5OIyzAvXXFcbypk67UgsGB1PnyFQONOV.', 0, NULL, NULL, '2026-09-16 19:55:59'),
(2, 'Saidul', 'male', '+8800177681174', 0, '$2b$12$N8Fa.hY5nVOtVXyKRNCDcOBpIDzRZp08Y2vbVWihmMmWNQoHEfqWi', 0, NULL, NULL, '2026-09-17 12:13:13'),
(6, 'Sabuj Mia', 'male', '+8801318118344', 1, '$2b$12$97OBnSy5ALMrBacYUhkb9.cHUxhsw6Tggrndl93AC5rchMBRCPRbu', 0, NULL, NULL, '2026-09-17 12:23:40'),
(7, 'RAbbi', 'male', '01755212813', 1, '$2b$12$M04jbCweHGSoDSFCnETWp.j5ow7rnfYSKKOrNMzmV2e1E2A2ymehu', 0, NULL, NULL, '2026-09-18 12:12:55'),
(101, 'Nusrat Jahan', NULL, '+8801700000101', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(102, 'Farhan Tanvir', NULL, '+8801700000102', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(103, 'Maliha Rahman', NULL, '+8801700000103', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(201, 'Rahul Hassan', NULL, '+8801800000201', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(202, 'Master Rahim C.', NULL, '+8801800000202', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(203, 'Priya Sen', NULL, '+8801800000203', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(204, 'Tanvir Alam', NULL, '+8801800000204', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(205, 'Ava Morgan', NULL, '+8801800000205', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(206, 'Sofia Karim', NULL, '+8801800000206', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(207, 'Rahim Uddin', NULL, '+8801800000207', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(208, 'Maya Chen', NULL, '+8801800000208', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(209, 'John Smith', NULL, '+8801800000209', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11'),
(210, 'Priya Ahmed', NULL, '+8801800000210', 1, '$2b$12$eHVojDxF7h77dXZ3GDa1Tu5c/qxRToDBbDD6MLqHHE/JqeGtwdLVq', 0, NULL, NULL, '2026-09-19 21:59:11');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alembic_version`
--
ALTER TABLE `alembic_version`
  ADD PRIMARY KEY (`version_num`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_bookings_client_id` (`client_id`),
  ADD KEY `fk_bookings_provider_id` (`provider_id`),
  ADD KEY `fk_bookings_category_id` (`category_id`);

--
-- Indexes for table `client_profiles`
--
ALTER TABLE `client_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `portfolio_items`
--
ALTER TABLE `portfolio_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_portfolio_items_provider_title` (`provider_id`,`title`);

--
-- Indexes for table `provider_profiles`
--
ALTER TABLE `provider_profiles`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_reviews_booking_id` (`booking_id`);

--
-- Indexes for table `service_categories`
--
ALTER TABLE `service_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_service_categories_name` (`name`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_users_phone` (`phone`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=507;

--
-- AUTO_INCREMENT for table `portfolio_items`
--
ALTER TABLE `portfolio_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_categories`
--
ALTER TABLE `service_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=211;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `fk_bookings_category_id` FOREIGN KEY (`category_id`) REFERENCES `service_categories` (`id`),
  ADD CONSTRAINT `fk_bookings_client_id` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_bookings_provider_id` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `client_profiles`
--
ALTER TABLE `client_profiles`
  ADD CONSTRAINT `fk_client_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `portfolio_items`
--
ALTER TABLE `portfolio_items`
  ADD CONSTRAINT `fk_portfolio_items_provider_id` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `provider_profiles`
--
ALTER TABLE `provider_profiles`
  ADD CONSTRAINT `fk_provider_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `fk_reviews_booking_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
