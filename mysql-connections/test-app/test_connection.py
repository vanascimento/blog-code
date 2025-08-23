#!/usr/bin/env python3
"""
Simple MySQL Connection Test
Tests if the connection to MySQL is working properly
"""

import mysql.connector
import sys
import argparse

def test_mysql_connection(port):
    """Test basic MySQL connection"""
    try:
        print(f"🔌 Testing MySQL connection on port {port}...")
        
        connection = mysql.connector.connect(
            host='localhost',
            port=port,
            user='root',
            password='rootpass',
            database='bank_db',
            auth_plugin='mysql_native_password'
        )
        
        if connection.is_connected():
            print("✅ Successfully connected to MySQL!")
            
            cursor = connection.cursor()
            
            # Test basic query
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()
            print(f"📊 MySQL Version: {version[0]}")
            
            # Test database access
            cursor.execute("SELECT COUNT(*) FROM TB_BANK_TRANSACTIONS")
            count = cursor.fetchone()[0]
            print(f"📈 Records in TB_BANK_TRANSACTIONS: {count}")
            
            # Test user authentication method
            cursor.execute("SELECT user, host, plugin FROM mysql.user WHERE user='root'")
            users = cursor.fetchall()
            print("\n👤 User Authentication Methods:")
            for user in users:
                print(f"   User: {user[0]}, Host: {user[1]}, Plugin: {user[2]}")
            
            cursor.close()
            connection.close()
            print("\n🎉 All tests passed! Connection is working properly.")
            return True
            
    except mysql.connector.Error as err:
        print(f"❌ MySQL Error: {err}")
        return False
    except Exception as e:
        print(f"❌ General Error: {e}")
        return False

if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='MySQL Connection Test')
    parser.add_argument('--port', type=int, default=3306, 
                       help='MySQL port (default: 3306)')
    args = parser.parse_args()
    
    success = test_mysql_connection(args.port)
    sys.exit(0 if success else 1)
