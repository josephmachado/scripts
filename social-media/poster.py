# Social media poster script
# Claude code

#!/usr/bin/env python3
"""
LinkedIn Post Automation using Selenium
Requires: pip install selenium
Also requires Firefox and geckodriver installed
"""

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.keys import Keys
import time

def post_to_linkedin(post_content):
    """
    Automate posting to LinkedIn using Selenium and Firefox
    
    Args:
        post_content (str): The content to post on LinkedIn
    """
    
    # Configure Firefox options
    firefox_options = Options()
    # Uncomment the next line to run in headless mode (without GUI)
    # firefox_options.add_argument("--headless")
    
    # Initialize Firefox driver
    driver = webdriver.Firefox(options=firefox_options)
    
    try:
        # Navigate to LinkedIn
        print("Opening LinkedIn...")
        driver.get("https://www.linkedin.com")
        
        # Wait for page to load and check if user is signed in
        wait = WebDriverWait(driver, 10)
        
        # Wait for either login form or feed to load
        try:
            # Check if we're on the feed (signed in)
            wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "[data-test-id='share-box-trigger']")))
            print("User is signed in. Proceeding to post...")
        except:
            print("User not signed in or LinkedIn layout changed. Please sign in manually.")
            input("Press Enter after signing in...")
        
        # Click on the "Start a post" button/area
        try:
            share_button = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "[data-test-id='share-box-trigger']")))
            share_button.click()
            print("Clicked share button...")
        except:
            # Alternative selector if the above doesn't work
            try:
                share_button = driver.find_element(By.XPATH, "//span[contains(text(), 'Start a post')]")
                share_button.click()
                print("Clicked share button (alternative method)...")
            except:
                print("Could not find share button. LinkedIn layout may have changed.")
                return False
        
        # Wait for the post composition modal to appear
        time.sleep(2)
        
        # Find the text area and enter the post content
        try:
            # Wait for the text editor to be available
            text_area = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "[data-test-id='share-form-text-area']")))
            text_area.clear()
            text_area.send_keys(post_content)
            print(f"Entered post content: {post_content[:50]}...")
        except:
            # Alternative approach - try different selectors
            try:
                text_area = driver.find_element(By.CSS_SELECTOR, "div[data-lexical-editor='true']")
                text_area.click()
                text_area.send_keys(post_content)
                print(f"Entered post content (alternative method): {post_content[:50]}...")
            except:
                print("Could not find text area. Please check the selectors.")
                return False
        
        # Wait a moment for the content to be processed
        time.sleep(1)
        
        # Find and click the Post button
        try:
            post_button = wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "[data-test-id='share-form-post-button']")))
            post_button.click()
            print("Post submitted successfully!")
            
            # Wait a moment to see the result
            time.sleep(3)
            return True
            
        except:
            # Alternative selector for post button
            try:
                post_button = driver.find_element(By.XPATH, "//span[contains(text(), 'Post')]")
                post_button.click()
                print("Post submitted successfully!")
                time.sleep(3)
                return True
            except:
                print("Could not find post button. You may need to click it manually.")
                return False
                
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return False
        
    finally:
        # Keep browser open for a few seconds to see the result
        print("Keeping browser open for 5 seconds...")
        time.sleep(5)
        
        # Uncomment the next line to automatically close the browser
        # driver.quit()
        
        print("Script completed. Browser will remain open.")


def main():
    # Your post content goes here
    s = """🚀 Excited to share my latest project! 

Working on automation tools that help streamline daily workflows. 
There's something deeply satisfying about turning repetitive tasks into elegant, automated solutions.

What's the most time-consuming task in your workflow that you wish you could automate?

#automation #productivity #python #coding"""
    
    print("Starting LinkedIn post automation...")
    print(f"Post content: {s}")
    
    success = post_to_linkedin(s)
    
    if success:
        print("✅ Post automation completed successfully!")
    else:
        print("❌ Post automation encountered issues. Please check manually.")


if __name__ == "__main__":
    main()
