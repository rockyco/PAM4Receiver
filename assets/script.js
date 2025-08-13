// PAM4 Receiver Website JavaScript
document.addEventListener('DOMContentLoaded', function() {
    
    // Mobile Navigation Toggle
    const navToggle = document.querySelector('.nav-toggle');
    const navMenu = document.querySelector('.nav-menu');
    
    if (navToggle && navMenu) {
        navToggle.addEventListener('click', function() {
            navMenu.classList.toggle('active');
            
            // Animate hamburger menu
            const bars = navToggle.querySelectorAll('.bar');
            bars.forEach((bar, index) => {
                if (navMenu.classList.contains('active')) {
                    if (index === 0) bar.style.transform = 'rotate(45deg) translate(5px, 5px)';
                    if (index === 1) bar.style.opacity = '0';
                    if (index === 2) bar.style.transform = 'rotate(-45deg) translate(7px, -6px)';
                } else {
                    bar.style.transform = 'none';
                    bar.style.opacity = '1';
                }
            });
        });
        
        // Close mobile menu when clicking on links
        const navLinks = document.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', () => {
                navMenu.classList.remove('active');
                const bars = navToggle.querySelectorAll('.bar');
                bars.forEach(bar => {
                    bar.style.transform = 'none';
                    bar.style.opacity = '1';
                });
            });
        });
    }
    
    // Smooth scrolling for navigation links
    const scrollLinks = document.querySelectorAll('a[href^="#"]');
    scrollLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                const headerOffset = 80; // Height of fixed navbar
                const elementPosition = targetElement.getBoundingClientRect().top;
                const offsetPosition = elementPosition + window.pageYOffset - headerOffset;
                
                window.scrollTo({
                    top: offsetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });
    
    // Navbar background on scroll
    const navbar = document.querySelector('.navbar');
    let lastScrollTop = 0;
    
    window.addEventListener('scroll', function() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        
        if (scrollTop > 100) {
            navbar.style.background = 'rgba(255, 255, 255, 0.98)';
            navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
        } else {
            navbar.style.background = 'rgba(255, 255, 255, 0.95)';
            navbar.style.boxShadow = 'none';
        }
        
        // Hide navbar on scroll down, show on scroll up
        if (scrollTop > lastScrollTop && scrollTop > 200) {
            navbar.style.transform = 'translateY(-100%)';
        } else {
            navbar.style.transform = 'translateY(0)';
        }
        
        lastScrollTop = scrollTop <= 0 ? 0 : scrollTop;
    });
    
    // Tabs functionality for implementations section
    const tabButtons = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            const targetTab = this.getAttribute('data-tab');
            
            // Remove active class from all buttons and contents
            tabButtons.forEach(btn => btn.classList.remove('active'));
            tabContents.forEach(content => content.classList.remove('active'));
            
            // Add active class to clicked button and corresponding content
            this.classList.add('active');
            const targetContent = document.getElementById(targetTab);
            if (targetContent) {
                targetContent.classList.add('active');
                
                // Animate content change
                targetContent.style.opacity = '0';
                targetContent.style.transform = 'translateY(20px)';
                
                setTimeout(() => {
                    targetContent.style.transition = 'all 0.3s ease-out';
                    targetContent.style.opacity = '1';
                    targetContent.style.transform = 'translateY(0)';
                }, 50);
            }
        });
    });
    
    // Scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate');
                
                // Add staggered animation delay for grid items
                const gridItems = entry.target.querySelectorAll('.overview-card, .agent-card, .component-card, .achievement, .stat-card');
                gridItems.forEach((item, index) => {
                    setTimeout(() => {
                        item.style.opacity = '1';
                        item.style.transform = 'translateY(0)';
                    }, index * 100);
                });
            }
        });
    }, observerOptions);
    
    // Observe elements for scroll animation
    const animateElements = document.querySelectorAll('.overview-grid, .achievements-grid, .agents-grid, .component-results, .framework-stats, .benefits-grid');
    animateElements.forEach(element => {
        element.classList.add('scroll-animate');
        observer.observe(element);
    });
    
    // Timeline animation
    const timelineItems = document.querySelectorAll('.timeline-item');
    const timelineObserver = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateX(0)';
            }
        });
    }, observerOptions);
    
    timelineItems.forEach((item, index) => {
        item.style.opacity = '0';
        item.style.transform = 'translateX(-50px)';
        item.style.transition = `all 0.6s ease-out ${index * 0.2}s`;
        timelineObserver.observe(item);
    });
    
    // Counter animation for statistics
    function animateCounter(element, target, duration = 2000) {
        let start = 0;
        const increment = target / (duration / 16);
        const timer = setInterval(() => {
            start += increment;
            if (start >= target) {
                element.textContent = target.toString();
                clearInterval(timer);
            } else {
                element.textContent = Math.floor(start).toString();
            }
        }, 16);
    }
    
    // Animate achievement numbers
    const achievementObserver = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const number = entry.target.querySelector('.achievement-number, .stat-number');
                if (number && !number.dataset.animated) {
                    number.dataset.animated = 'true';
                    const text = number.textContent;
                    const value = parseFloat(text.replace(/[^\d.]/g, ''));
                    if (!isNaN(value)) {
                        number.textContent = '0';
                        setTimeout(() => {
                            animateCounter(number, value);
                            // Restore original formatting
                            setTimeout(() => {
                                number.textContent = text;
                            }, 2000);
                        }, 300);
                    }
                }
            }
        });
    }, observerOptions);
    
    const achievements = document.querySelectorAll('.achievement, .stat-card');
    achievements.forEach(achievement => {
        achievementObserver.observe(achievement);
    });
    
    // Image lazy loading with fade-in effect
    const images = document.querySelectorAll('img');
    const imageObserver = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.style.opacity = '0';
                img.style.transition = 'opacity 0.6s ease-out';
                
                if (img.dataset.src) {
                    img.src = img.dataset.src;
                }
                
                img.onload = function() {
                    this.style.opacity = '1';
                };
                
                imageObserver.unobserve(img);
            }
        });
    });
    
    images.forEach(img => {
        // Add fade-in effect to all images
        img.style.opacity = '0';
        img.style.transition = 'opacity 0.6s ease-out';
        
        // If image is already loaded, fade it in
        if (img.complete) {
            img.style.opacity = '1';
        } else {
            img.onload = function() {
                this.style.opacity = '1';
            };
        }
        
        imageObserver.observe(img);
    });
    
    // Parallax effect for hero section
    const hero = document.querySelector('.hero');
    if (hero) {
        window.addEventListener('scroll', function() {
            const scrolled = window.pageYOffset;
            const speed = scrolled * 0.5;
            hero.style.transform = `translateY(${speed}px)`;
        });
    }
    
    // Copy to clipboard functionality for code blocks
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach(block => {
        const button = document.createElement('button');
        button.innerHTML = '<i class="fas fa-copy"></i>';
        button.className = 'copy-btn';
        button.style.cssText = `
            position: absolute;
            top: 0.5rem;
            right: 0.5rem;
            padding: 0.5rem;
            background: rgba(255, 255, 255, 0.1);
            border: none;
            border-radius: 0.25rem;
            color: white;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s ease;
        `;
        
        const pre = block.parentElement;
        pre.style.position = 'relative';
        pre.appendChild(button);
        
        pre.addEventListener('mouseenter', () => {
            button.style.opacity = '1';
        });
        
        pre.addEventListener('mouseleave', () => {
            button.style.opacity = '0';
        });
        
        button.addEventListener('click', async () => {
            try {
                await navigator.clipboard.writeText(block.textContent);
                button.innerHTML = '<i class="fas fa-check"></i>';
                setTimeout(() => {
                    button.innerHTML = '<i class="fas fa-copy"></i>';
                }, 1500);
            } catch (err) {
                console.error('Failed to copy text: ', err);
            }
        });
    });
    
    // Performance metrics animation
    const performanceTable = document.querySelector('.comparison-table');
    if (performanceTable) {
        const tableObserver = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const rows = entry.target.querySelectorAll('tbody tr');
                    rows.forEach((row, index) => {
                        setTimeout(() => {
                            row.style.opacity = '1';
                            row.style.transform = 'translateX(0)';
                        }, index * 100);
                    });
                }
            });
        }, observerOptions);
        
        const rows = performanceTable.querySelectorAll('tbody tr');
        rows.forEach(row => {
            row.style.opacity = '0';
            row.style.transform = 'translateX(-20px)';
            row.style.transition = 'all 0.4s ease-out';
        });
        
        tableObserver.observe(performanceTable);
    }
    
    // Search functionality (if search box is added)
    const searchInput = document.querySelector('#search-input');
    if (searchInput) {
        let searchTimeout;
        
        searchInput.addEventListener('input', function() {
            clearTimeout(searchTimeout);
            const query = this.value.toLowerCase().trim();
            
            searchTimeout = setTimeout(() => {
                if (query.length > 2) {
                    highlightSearchResults(query);
                } else {
                    clearSearchHighlights();
                }
            }, 300);
        });
        
        function highlightSearchResults(query) {
            const elements = document.querySelectorAll('h1, h2, h3, h4, p, li');
            elements.forEach(element => {
                const text = element.textContent.toLowerCase();
                if (text.includes(query)) {
                    element.style.background = 'rgba(59, 130, 246, 0.1)';
                    element.style.transition = 'background 0.3s ease';
                }
            });
        }
        
        function clearSearchHighlights() {
            const highlighted = document.querySelectorAll('[style*="background"]');
            highlighted.forEach(element => {
                element.style.background = 'none';
            });
        }
    }
    
    // Easter egg - Konami code
    let konamiCode = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
    let userInput = [];
    
    document.addEventListener('keydown', function(e) {
        userInput.push(e.keyCode);
        if (userInput.length > konamiCode.length) {
            userInput.shift();
        }
        
        if (JSON.stringify(userInput) === JSON.stringify(konamiCode)) {
            showEasterEgg();
            userInput = [];
        }
    });
    
    function showEasterEgg() {
        const easterEgg = document.createElement('div');
        easterEgg.innerHTML = `
            <div style="
                position: fixed;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 2rem;
                border-radius: 1rem;
                text-align: center;
                box-shadow: 0 20px 40px rgba(0,0,0,0.2);
                z-index: 10000;
                animation: bounceIn 0.6s ease-out;
            ">
                <h3>🎉 Easter Egg Unlocked!</h3>
                <p>PAM4 Receiver achieves 96.08% accuracy!</p>
                <p style="margin-top: 1rem; opacity: 0.8; font-size: 0.9rem;">
                    The MATLAB2HDL framework transformation is complete!
                </p>
            </div>
        `;
        
        document.body.appendChild(easterEgg);
        
        setTimeout(() => {
            easterEgg.style.animation = 'fadeOut 0.6s ease-out';
            setTimeout(() => {
                document.body.removeChild(easterEgg);
            }, 600);
        }, 3000);
        
        // Add CSS for animations
        if (!document.getElementById('easter-egg-styles')) {
            const style = document.createElement('style');
            style.id = 'easter-egg-styles';
            style.textContent = `
                @keyframes bounceIn {
                    0% { transform: translate(-50%, -50%) scale(0.3); opacity: 0; }
                    50% { transform: translate(-50%, -50%) scale(1.05); }
                    70% { transform: translate(-50%, -50%) scale(0.9); }
                    100% { transform: translate(-50%, -50%) scale(1); opacity: 1; }
                }
                @keyframes fadeOut {
                    from { opacity: 1; transform: translate(-50%, -50%) scale(1); }
                    to { opacity: 0; transform: translate(-50%, -50%) scale(0.9); }
                }
            `;
            document.head.appendChild(style);
        }
    }
    
    // Performance optimization - Debounce scroll events
    function debounce(func, wait, immediate) {
        let timeout;
        return function executedFunction() {
            const context = this;
            const args = arguments;
            const later = function() {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            const callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    }
    
    // Apply debouncing to scroll events
    const debouncedScroll = debounce(function() {
        // Scroll-based animations can be added here if needed
    }, 10);
    
    window.addEventListener('scroll', debouncedScroll);
    
    // Initialize grid layouts with dynamic heights
    function initializeGrids() {
        const grids = document.querySelectorAll('.overview-grid, .component-results, .agents-grid');
        grids.forEach(grid => {
            const items = grid.children;
            let maxHeight = 0;
            
            // Reset heights
            Array.from(items).forEach(item => {
                item.style.height = 'auto';
            });
            
            // Find max height
            Array.from(items).forEach(item => {
                maxHeight = Math.max(maxHeight, item.offsetHeight);
            });
            
            // Apply max height to all items
            Array.from(items).forEach(item => {
                item.style.height = maxHeight + 'px';
            });
        });
    }
    
    // Initialize grids on load and resize
    initializeGrids();
    window.addEventListener('resize', debounce(initializeGrids, 250));
    
    // Print functionality
    window.addEventListener('beforeprint', function() {
        // Expand all tabs for printing
        tabContents.forEach(content => {
            content.classList.add('active');
        });
    });
    
    window.addEventListener('afterprint', function() {
        // Restore tab state
        tabContents.forEach(content => {
            content.classList.remove('active');
        });
        // Restore active tab
        const activeTab = document.querySelector('.tab-btn.active');
        if (activeTab) {
            const targetTab = activeTab.getAttribute('data-tab');
            const targetContent = document.getElementById(targetTab);
            if (targetContent) {
                targetContent.classList.add('active');
            }
        }
    });
    
    console.log('🚀 PAM4 Receiver Website Loaded Successfully!');
    console.log('📊 Performance: 96.08% Decision Accuracy');
    console.log('⚡ Frequency: 300+ MHz Target');
    console.log('🔧 DSP Reduction: 86%');
    console.log('Try the Konami code: ↑↑↓↓←→←→BA');
});