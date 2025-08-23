#!/usr/bin/env python3
"""
Simple MySQL Load Test
Executes 50 SELECT queries per second on TB_BANK_TRANSACTIONS table
"""

import mysql.connector
import time
import threading
import sys
import argparse
from datetime import datetime

def test_connection(port):
    """Test database connection"""
    try:
        connection = mysql.connector.connect(
            host='localhost',
            port=port,
            user='root',
            password='rootpass',
            database='bank_db',
            auth_plugin='mysql_native_password'
        )
        
        cursor = connection.cursor()
        cursor.execute("SELECT COUNT(*) FROM TB_BANK_TRANSACTIONS")
        count = cursor.fetchone()[0]
        print(f"✅ Connected! Table has {count} records")
        
        cursor.close()
        #connection.close()
        return True
        
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False

def execute_query(connection, query_id):
    """Execute a single SELECT query"""
    start_time = time.time()
    
    try:
        cursor = connection.cursor()
        
        # Simple queries to test
        queries = [
            "SELECT COUNT(*) FROM TB_BANK_TRANSACTIONS",
            "SELECT * FROM TB_BANK_TRANSACTIONS WHERE transaction_type = 'DEPOSIT' LIMIT 5",
            "SELECT * FROM TB_BANK_TRANSACTIONS WHERE amount > 1000 LIMIT 5",
            "SELECT transaction_type, COUNT(*) FROM TB_BANK_TRANSACTIONS GROUP BY transaction_type"
        ]
        
        # Use query_id to cycle through queries
        query = queries[query_id % len(queries)]
        
        cursor.execute(query)
        result = cursor.fetchall()
        cursor.close()
        
        execution_time = (time.time() - start_time) * 1000
        print(f"Query {query_id}: {execution_time:.2f}ms - {query[:50]}...")
        
        return True, execution_time
        
    except Exception as e:
        execution_time = (time.time() - start_time) * 1000
        print(f"Query {query_id} failed: {e}")
        return False, execution_time

def load_test_worker(thread_id, queries_per_second, duration, results, port):
    """Worker thread for load testing"""

    
    try:
        query_id = thread_id * 1000
        start_time = time.time()
        
        while time.time() - start_time < duration:
            thread_start = time.time()
            
            # Execute queries for this second
            for i in range(queries_per_second):
                if time.time() - start_time >= duration:
                    break
                
                connection = mysql.connector.connect(
                    host='localhost',
                    port=port,
                    user='root',
                    password='rootpass',
                    database='bank_db',
                    auth_plugin='mysql_native_password',
                    
                )
                    
                success, exec_time = execute_query(connection, query_id + i)
                results.append({
                    'success': success,
                    'time': exec_time,
                    'thread': thread_id
                })
                query_id += 1
                #connection.close()
            
            # Sleep to maintain rate
            elapsed = time.time() - thread_start
            if elapsed < 1.0:
                time.sleep(1.0 - elapsed)
                
    except Exception as e:
        print(f"Thread {thread_id} error: {e}")

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='MySQL Load Test')
    parser.add_argument('--port', type=int, default=3306, 
                       help='MySQL port (default: 3306)')
    args = parser.parse_args()
    
    port = args.port
    
    print("🚀 Simple MySQL Load Test")
    print("=" * 40)
    print(f"🔌 Connecting to MySQL on port {port}")
    print("=" * 40)
    
    # Test connection first
    if not test_connection(port):
        print("❌ Cannot continue without database connection")
        return
    
    # Configuration
    DURATION = 600  # seconds
    QPS = 1000       # queries per second
    THREADS = 50    # number of threads
    
    print(f"📊 Target: {QPS} queries/second")
    print(f"⏱️  Duration: {DURATION} seconds")
    print(f"🧵 Threads: {THREADS}")
    print(f"🎯 Total queries: {QPS * DURATION}")
    print("-" * 40)
    
    # Start load test
    results = []
    threads = []
    
    # Calculate queries per thread
    qps_per_thread = QPS // THREADS
    
    # Start threads
    for i in range(THREADS):
        thread = threading.Thread(
            target=load_test_worker,
            args=(i, qps_per_thread, DURATION, results, port)
        )
        thread.start()
        threads.append(thread)
    
    # Monitor progress
    start_time = time.time()
    last_count = 0
    
    try:
        while time.time() - start_time < DURATION:
            time.sleep(1)
            
            current_count = len(results)
            queries_this_second = current_count - last_count
            elapsed = time.time() - start_time
            
            print(f"⏱️  {elapsed:.1f}s | 📊 {current_count} queries | 🚀 {queries_this_second}/s")
            last_count = current_count
            
    except KeyboardInterrupt:
        print("\n⚠️  Test interrupted by user")
    
    # Wait for threads to finish
    for thread in threads:
        thread.join()
    
    # Show results
    print("\n" + "=" * 40)
    print("📊 TEST RESULTS")
    print("=" * 40)
    
    if results:
        successful = sum(1 for r in results if r['success'])
        failed = len(results) - successful
        
        print(f"🎯 Total Queries: {len(results)}")
        print(f"✅ Successful: {successful}")
        print(f"❌ Failed: {failed}")
        print(f"📈 Success Rate: {(successful / len(results)) * 100:.1f}%")
        
        if successful > 0:
            times = [r['time'] for r in results if r['success']]
            print(f"\n⏱️  PERFORMANCE")
            print(f"   Fastest: {min(times):.2f}ms")
            print(f"   Slowest: {max(times):.2f}ms")
            print(f"   Average: {sum(times) / len(times):.2f}ms")
        
        # Calculate actual QPS
        duration = time.time() - start_time
        actual_qps = len(results) / duration
        print(f"\n🎯 ACTUAL QPS: {actual_qps:.1f}")
    
    print("=" * 40)

if __name__ == "__main__":
    main()
