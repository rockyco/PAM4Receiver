// JavaScript to fix image paths dynamically
document.addEventListener('DOMContentLoaded', function() {
    // Function to fix image paths
    function fixImagePaths() {
        const images = document.querySelectorAll('img[src^="images/"]');
        
        images.forEach(img => {
            const originalSrc = img.src;
            const imageName = img.getAttribute('src');
            
            console.log(`Checking image: ${imageName}`);
            
            // Test if the image loads
            const testImg = new Image();
            testImg.onload = function() {
                console.log(`✅ Image loads correctly: ${imageName}`);
            };
            
            testImg.onerror = function() {
                console.log(`❌ Image failed to load: ${imageName}`);
                
                // Try different path variations
                const variations = [
                    `./${imageName}`,
                    `/${imageName}`,
                    `/PAM4Receiver/${imageName}`,
                    window.location.pathname.replace(/\/[^/]*$/, '/') + imageName
                ];
                
                tryImageVariations(img, variations, 0);
            };
            
            testImg.src = img.src;
        });
    }
    
    function tryImageVariations(img, variations, index) {
        if (index >= variations.length) {
            console.log(`❌ All variations failed for image: ${img.getAttribute('src')}`);
            img.style.border = '2px solid red';
            img.alt = 'IMAGE NOT FOUND: ' + img.alt;
            return;
        }
        
        const testImg = new Image();
        const variation = variations[index];
        
        testImg.onload = function() {
            console.log(`✅ Found working path: ${variation}`);
            img.src = variation;
        };
        
        testImg.onerror = function() {
            console.log(`❌ Failed variation: ${variation}`);
            tryImageVariations(img, variations, index + 1);
        };
        
        testImg.src = variation;
    }
    
    // Run the fix
    setTimeout(fixImagePaths, 100); // Small delay to ensure DOM is ready
});