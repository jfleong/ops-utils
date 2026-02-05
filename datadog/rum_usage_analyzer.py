"""
This script processes RUM usage data exported from the Datadog usage page.
It extracts RUM Sessions and RUM with Session Replay Sessions usage, groups by service,
and splits usage equally when multiple services are present.
"""

import csv
from collections import defaultdict


def main():
    # Read the CSV file
    rum_data = []
    with open("2026-01.csv", "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            product_name = row["Product Name"]
            # Filter rows with RUM products
            if product_name in ["RUM with Session Replay Sessions", "RUM Sessions"]:
                rum_data.append(row)

    # Group usage by service and product type, splitting equally for multiple services
    # Structure: service_usage[service][product_name] = usage
    service_usage = defaultdict(lambda: defaultdict(float))

    for row in rum_data:
        product_name = row["Product Name"]
        usage = float(row["Usage"])
        services = row["service"].strip()

        if services:  # Only process if service field is not empty
            # Split services by "|" and strip whitespace
            service_list = [s.strip() for s in services.split("|") if s.strip()]

            if service_list:
                # Split usage equally among all services
                usage_per_service = usage / len(service_list)
                for service in service_list:
                    service_usage[service][product_name] += usage_per_service

    # Write to output CSV
    output_filename = "rum_usage_by_service.csv"
    with open(output_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        # Write header
        writer.writerow(["service", "RUM Sessions", "RUM with session replay sessions"])

        # Write data sorted by total usage (descending)
        sorted_services = sorted(
            service_usage.items(),
            key=lambda x: x[1]["RUM Sessions"]
            + x[1]["RUM with Session Replay Sessions"],
            reverse=True,
        )

        for service, usage_by_product in sorted_services:
            rum_sessions = usage_by_product.get("RUM Sessions", 0.0)
            rum_with_replay = usage_by_product.get(
                "RUM with Session Replay Sessions", 0.0
            )
            writer.writerow([service, rum_sessions, rum_with_replay])

    print(f"Output written to {output_filename}")


if __name__ == "__main__":
    main()

