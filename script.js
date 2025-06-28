// Personal Wellness Logger - Main JavaScript File

class WellnessLogger {
    constructor() {
        this.storageKey = 'wellness_log_data';
        this.currentEditId = null;
        this.currentDeleteId = null;
        this.currentView = 'list';
        this.currentDate = new Date();
        this.currentFilters = {
            searchText: '',
            type: '',
            dateRange: '',
            dateFrom: '',
            dateTo: ''
        };
        this.allEntries = []; // Cache for filtering
        this.filteredEntries = []; // Cache for filtered results
        this.init();
    }

    init() {
        this.bindEvents();
        this.renderEntries();
        this.renderCalendar();
        this.initMobileEnhancements();
    }

    bindEvents() {
        // View toggle buttons
        document.getElementById('list-view-btn').addEventListener('click', () => this.switchView('list'));
        document.getElementById('calendar-view-btn').addEventListener('click', () => this.switchView('calendar'));
        document.getElementById('analytics-view-btn').addEventListener('click', () => this.switchView('analytics'));

        // Quick log buttons
        document.getElementById('log-exercise').addEventListener('click', () => this.logExercise());
        document.getElementById('log-svt').addEventListener('click', () => this.logSVTEpisode());
        document.getElementById('log-medication').addEventListener('click', () => this.logMedication());

        // Data management buttons
        document.getElementById('export-csv').addEventListener('click', () => this.exportCSV());
        document.getElementById('export-filtered-csv').addEventListener('click', () => this.exportFilteredCSV());
        document.getElementById('export-data').addEventListener('click', () => this.exportData());
        document.getElementById('import-data').addEventListener('click', () => this.importData());
        document.getElementById('file-input').addEventListener('change', (e) => this.handleFileImport(e));

        // Calendar navigation
        document.getElementById('prev-month').addEventListener('click', () => this.navigateMonth(-1));
        document.getElementById('next-month').addEventListener('click', () => this.navigateMonth(1));

        // Modal events
        document.getElementById('close-modal').addEventListener('click', () => this.closeEditModal());
        document.getElementById('cancel-edit').addEventListener('click', () => this.closeEditModal());
        document.getElementById('edit-form').addEventListener('submit', (e) => this.handleEditSubmit(e));

        // Confirmation modal events
        document.getElementById('cancel-delete').addEventListener('click', () => this.closeConfirmModal());
        document.getElementById('confirm-delete').addEventListener('click', () => this.confirmDelete());

        // Day modal events
        document.getElementById('close-day-modal').addEventListener('click', () => this.closeDayModal());

        // Search and filter events
        document.getElementById('search-input').addEventListener('input', (e) => this.handleSearch(e.target.value));
        document.getElementById('clear-search').addEventListener('click', () => this.clearSearch());
        document.getElementById('type-filter').addEventListener('change', (e) => this.handleTypeFilter(e.target.value));
        document.getElementById('date-range-filter').addEventListener('change', (e) => this.handleDateRangeFilter(e.target.value));
        document.getElementById('apply-date-range').addEventListener('click', () => this.applyCustomDateRange());
        document.getElementById('clear-filters').addEventListener('click', () => this.clearAllFilters());

        // Close modals when clicking outside
        window.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                this.closeEditModal();
                this.closeConfirmModal();
                this.closeDayModal();
            }
        });
    }

    // View Management
    switchView(view) {
        this.currentView = view;
        
        // Update button states
        document.getElementById('list-view-btn').classList.toggle('active', view === 'list');
        document.getElementById('calendar-view-btn').classList.toggle('active', view === 'calendar');
        document.getElementById('analytics-view-btn').classList.toggle('active', view === 'analytics');
        
        // Show/hide sections
        document.getElementById('list-section').style.display = view === 'list' ? 'block' : 'none';
        document.getElementById('calendar-section').style.display = view === 'calendar' ? 'block' : 'none';
        document.getElementById('analytics-section').style.display = view === 'analytics' ? 'block' : 'none';
        
        if (view === 'calendar') {
            this.renderCalendar();
        } else if (view === 'analytics') {
            this.renderAnalytics();
        }
    }

    // Calendar Functions
    navigateMonth(direction) {
        this.currentDate.setMonth(this.currentDate.getMonth() + direction);
        this.renderCalendar();
    }

    renderCalendar() {
        const year = this.currentDate.getFullYear();
        const month = this.currentDate.getMonth();
        
        // Update calendar title
        const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December'
        ];
        document.getElementById('calendar-title').textContent = `${monthNames[month]} ${year}`;
        
        // Get calendar data
        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const startDate = new Date(firstDay);
        startDate.setDate(startDate.getDate() - firstDay.getDay());
        
        const endDate = new Date(lastDay);
        endDate.setDate(endDate.getDate() + (6 - lastDay.getDay()));
        
        // Get entries for this month
        const data = this.getData();
        const entriesByDate = this.groupEntriesByDate(data);
        
        // Generate calendar grid
        const grid = document.getElementById('calendar-grid');
        grid.innerHTML = '';
        
        // Add day headers
        const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        dayHeaders.forEach(day => {
            const header = document.createElement('div');
            header.className = 'day-header';
            header.textContent = day;
            grid.appendChild(header);
        });
        
        // Add calendar days
        const today = new Date();
        const currentDate = new Date(startDate);
        
        while (currentDate <= endDate) {
            const dayElement = this.createCalendarDay(currentDate, month, today, entriesByDate);
            grid.appendChild(dayElement);
            currentDate.setDate(currentDate.getDate() + 1);
        }
    }

    createCalendarDay(date, currentMonth, today, entriesByDate) {
        const dayElement = document.createElement('div');
        dayElement.className = 'calendar-day';
        
        const dateKey = this.formatDateKey(date);
        const dayEntries = entriesByDate[dateKey] || [];
        
        // Add classes
        if (date.getMonth() !== currentMonth) {
            dayElement.classList.add('other-month');
        }
        
        if (this.isSameDay(date, today)) {
            dayElement.classList.add('today');
        }
        
        // Day number
        const dayNumber = document.createElement('div');
        dayNumber.className = 'day-number';
        dayNumber.textContent = date.getDate();
        dayElement.appendChild(dayNumber);
        
        // Event dots
        if (dayEntries.length > 0) {
            const eventsContainer = document.createElement('div');
            eventsContainer.className = 'day-events';
            
            const eventCounts = this.countEventsByType(dayEntries);
            
            Object.entries(eventCounts).forEach(([type, count]) => {
                for (let i = 0; i < Math.min(count, 3); i++) {
                    const dot = document.createElement('div');
                    dot.className = `event-dot ${type.toLowerCase().replace(' ', '')}`;
                    eventsContainer.appendChild(dot);
                }
            });
            
            dayElement.appendChild(eventsContainer);
            
            // Click handler to show day details
            dayElement.addEventListener('click', () => this.showDayModal(date, dayEntries));
            dayElement.style.cursor = 'pointer';
        }
        
        return dayElement;
    }

    groupEntriesByDate(entries) {
        const grouped = {};
        entries.forEach(entry => {
            const date = new Date(entry.timestamp);
            const key = this.formatDateKey(date);
            if (!grouped[key]) {
                grouped[key] = [];
            }
            grouped[key].push(entry);
        });
        return grouped;
    }

    countEventsByType(entries) {
        const counts = {};
        entries.forEach(entry => {
            // Map entry types to CSS class names
            let type = entry.type.toLowerCase();
            if (type === 'svt episode') {
                type = 'svt';
            } else {
                type = type.replace(' ', '');
            }
            counts[type] = (counts[type] || 0) + 1;
        });
        return counts;
    }

    formatDateKey(date) {
        // Use local date components to avoid timezone shifts
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    isSameDay(date1, date2) {
        return date1.toDateString() === date2.toDateString();
    }

    // Day Modal
    showDayModal(date, entries) {
        const modal = document.getElementById('day-modal');
        const title = document.getElementById('day-modal-title');
        const container = document.getElementById('day-entries');
        
        title.textContent = `Entries for ${date.toLocaleDateString()}`;
        
        if (entries.length === 0) {
            container.innerHTML = '<p class="no-entries">No entries for this day.</p>';
        } else {
            container.innerHTML = entries
                .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp))
                .map(entry => this.createDayEntryHTML(entry))
                .join('');
            
            // Bind event listeners for edit and delete buttons
            container.querySelectorAll('.edit-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const id = e.target.dataset.id;
                    this.closeDayModal();
                    this.editEntry(id);
                });
            });
            
            container.querySelectorAll('.delete-btn').forEach(btn => {
                btn.addEventListener('click', (e) => {
                    const id = e.target.dataset.id;
                    this.closeDayModal();
                    this.deleteEntry(id);
                });
            });
        }
        
        modal.style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    closeDayModal() {
        document.getElementById('day-modal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    createDayEntryHTML(entry) {
        const date = new Date(entry.timestamp);
        const formattedTime = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        const icon = this.getEntryIcon(entry.type);
        const details = this.formatEntryDetailsShort(entry);
        
        return `
            <div class="day-entry">
                <div class="day-entry-info">
                    <div class="day-entry-type">
                        <span class="icon">${icon}</span>
                        ${entry.type}
                    </div>
                    <div class="day-entry-time">${formattedTime}</div>
                    <div class="day-entry-details">${details}</div>
                </div>
                <div class="day-entry-actions">
                    <button class="entry-btn edit-btn" data-id="${entry.id}">Edit</button>
                    <button class="entry-btn delete-btn" data-id="${entry.id}">Delete</button>
                </div>
            </div>
        `;
    }

    formatEntryDetailsShort(entry) {
        const details = [];
        
        if (entry.details.duration) {
            details.push(`Duration: ${entry.details.duration}`);
        }
        
        if (entry.details.dosage) {
            details.push(`Dosage: ${entry.details.dosage}`);
        }
        
        if (entry.details.comments) {
            details.push(`Comments: ${entry.details.comments}`);
        }
        
        return details.length > 0 ? details.join(' • ') : 'No additional details';
    }

    // Data Management
    getData() {
        const data = localStorage.getItem(this.storageKey);
        return data ? JSON.parse(data) : [];
    }

    saveData(data) {
        localStorage.setItem(this.storageKey, JSON.stringify(data));
    }

    generateId() {
        return Date.now() + Math.random().toString(36).substr(2, 9);
    }

    getCurrentTimestamp() {
        return new Date().toISOString();
    }

    // Quick Log Functions
    logExercise() {
        const entry = {
            id: this.generateId(),
            type: 'Exercise',
            timestamp: this.getCurrentTimestamp(),
            details: {
                comments: ''
            }
        };
        this.addEntry(entry);
    }

    logSVTEpisode() {
        const entry = {
            id: this.generateId(),
            type: 'SVT Episode',
            timestamp: this.getCurrentTimestamp(),
            details: {
                duration: '1 minute',
                comments: ''
            }
        };
        this.addEntry(entry);
    }

    logMedication() {
        const entry = {
            id: this.generateId(),
            type: 'Medication',
            timestamp: this.getCurrentTimestamp(),
            details: {
                dosage: '1/2 tablet',
                comments: ''
            }
        };
        this.addEntry(entry);
    }

    addEntry(entry) {
        const data = this.getData();
        data.push(entry);
        this.saveData(data);
        this.renderEntries();
        if (this.currentView === 'calendar') {
            this.renderCalendar();
        } else if (this.currentView === 'analytics') {
            this.renderAnalytics();
        }
        this.showSuccessMessage(`${entry.type} logged successfully!`);
    }

    // Entry Management
    editEntry(id) {
        const data = this.getData();
        const entry = data.find(item => item.id === id);
        if (!entry) return;

        this.currentEditId = id;
        this.populateEditForm(entry);
        this.showEditModal();
    }

    deleteEntry(id) {
        this.currentDeleteId = id;
        this.showConfirmModal();
    }

    confirmDelete() {
        if (!this.currentDeleteId) return;

        const data = this.getData();
        const filteredData = data.filter(item => item.id !== this.currentDeleteId);
        this.saveData(filteredData);
        this.renderEntries();
        if (this.currentView === 'calendar') {
            this.renderCalendar();
        } else if (this.currentView === 'analytics') {
            this.renderAnalytics();
        }
        this.closeConfirmModal();
        this.showSuccessMessage('Entry deleted successfully!');
        this.currentDeleteId = null;
    }

    // Modal Management
    showEditModal() {
        document.getElementById('edit-modal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    closeEditModal() {
        document.getElementById('edit-modal').style.display = 'none';
        document.body.style.overflow = 'auto';
        this.currentEditId = null;
        this.resetEditForm();
    }

    showConfirmModal() {
        document.getElementById('confirm-modal').style.display = 'block';
        document.body.style.overflow = 'hidden';
    }

    closeConfirmModal() {
        document.getElementById('confirm-modal').style.display = 'none';
        document.body.style.overflow = 'auto';
        this.currentDeleteId = null;
    }

    populateEditForm(entry) {
        const date = new Date(entry.timestamp);
        const localDate = new Date(date.getTime() - date.getTimezoneOffset() * 60000);
        
        document.getElementById('edit-date').value = localDate.toISOString().split('T')[0];
        document.getElementById('edit-time').value = localDate.toTimeString().slice(0, 5);
        document.getElementById('edit-comments').value = entry.details.comments || '';

        // Show/hide relevant fields based on entry type
        const durationGroup = document.getElementById('duration-group');
        const dosageGroup = document.getElementById('dosage-group');
        
        if (entry.type === 'SVT Episode') {
            durationGroup.style.display = 'block';
            dosageGroup.style.display = 'none';
            document.getElementById('edit-duration').value = entry.details.duration || '';
        } else if (entry.type === 'Medication') {
            durationGroup.style.display = 'none';
            dosageGroup.style.display = 'block';
            document.getElementById('edit-dosage').value = entry.details.dosage || '';
        } else {
            durationGroup.style.display = 'none';
            dosageGroup.style.display = 'none';
        }

        document.getElementById('modal-title').textContent = `Edit ${entry.type}`;
    }

    resetEditForm() {
        document.getElementById('edit-form').reset();
        document.getElementById('duration-group').style.display = 'none';
        document.getElementById('dosage-group').style.display = 'none';
    }

    handleEditSubmit(e) {
        e.preventDefault();
        
        if (!this.currentEditId) return;

        const data = this.getData();
        const entryIndex = data.findIndex(item => item.id === this.currentEditId);
        if (entryIndex === -1) return;

        const entry = data[entryIndex];
        const dateValue = document.getElementById('edit-date').value;
        const timeValue = document.getElementById('edit-time').value;
        
        // Combine date and time
        const newTimestamp = new Date(`${dateValue}T${timeValue}`).toISOString();
        
        entry.timestamp = newTimestamp;
        entry.details.comments = document.getElementById('edit-comments').value;

        if (entry.type === 'SVT Episode') {
            entry.details.duration = document.getElementById('edit-duration').value;
        } else if (entry.type === 'Medication') {
            entry.details.dosage = document.getElementById('edit-dosage').value;
        }

        this.saveData(data);
        this.renderEntries();
        if (this.currentView === 'calendar') {
            this.renderCalendar();
        } else if (this.currentView === 'analytics') {
            this.renderAnalytics();
        }
        this.closeEditModal();
        this.showSuccessMessage('Entry updated successfully!');
    }

    // Data Import/Export
    exportCSV() {
        const data = this.getData();
        
        if (data.length === 0) {
            this.showErrorMessage('No data to export. Please add some entries first.');
            return;
        }

        // Create CSV content
        const csvContent = this.generateCSVContent(data);
        
        // Create and download file
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        
        // Generate filename with date range
        const sortedData = data.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        const startDate = new Date(sortedData[0].timestamp).toISOString().split('T')[0];
        const endDate = new Date(sortedData[sortedData.length - 1].timestamp).toISOString().split('T')[0];
        
        link.download = `wellness_log_${startDate}_to_${endDate}.csv`;
        link.click();
        
        this.showSuccessMessage(`CSV exported successfully! ${data.length} entries included.`);
    }

    exportFilteredCSV() {
        if (this.filteredEntries.length === 0) {
            this.showErrorMessage('No filtered data to export. Please adjust your filters.');
            return;
        }

        // Create CSV content from filtered data
        const csvContent = this.generateCSVContent(this.filteredEntries);
        
        // Create and download file
        const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        
        // Generate filename with filter description
        const today = new Date().toISOString().split('T')[0];
        const filterDesc = this.getFilterDescription();
        link.download = `wellness_log_filtered_${filterDesc}_${today}.csv`;
        link.click();
        
        this.showSuccessMessage(`Filtered CSV exported successfully! ${this.filteredEntries.length} entries included.`);
    }

    getFilterDescription() {
        const parts = [];
        
        if (this.currentFilters.type) {
            parts.push(this.currentFilters.type.toLowerCase().replace(' ', ''));
        }
        
        if (this.currentFilters.dateRange) {
            parts.push(this.currentFilters.dateRange);
        } else if (this.currentFilters.dateFrom || this.currentFilters.dateTo) {
            if (this.currentFilters.dateFrom && this.currentFilters.dateTo) {
                parts.push(`${this.currentFilters.dateFrom}_to_${this.currentFilters.dateTo}`);
            } else if (this.currentFilters.dateFrom) {
                parts.push(`from_${this.currentFilters.dateFrom}`);
            } else {
                parts.push(`to_${this.currentFilters.dateTo}`);
            }
        }
        
        if (this.currentFilters.searchText) {
            parts.push('search');
        }
        
        return parts.length > 0 ? parts.join('_') : 'custom';
    }

    generateCSVContent(data) {
        // Define CSV headers - medical professional friendly
        const headers = [
            'Date',
            'Time',
            'Type',
            'Duration',
            'Dosage',
            'Comments'
        ];
        
        // Start with headers
        let csvContent = headers.join(',') + '\n';
        
        // Sort data by timestamp (oldest first for medical review)
        const sortedData = data.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        
        // Add data rows
        sortedData.forEach(entry => {
            const date = new Date(entry.timestamp);
            const formattedDate = date.toLocaleDateString('en-US'); // MM/DD/YYYY format
            const formattedTime = date.toLocaleTimeString('en-US', { 
                hour: '2-digit', 
                minute: '2-digit',
                hour12: true 
            });
            
            const row = [
                this.escapeCSVField(formattedDate),
                this.escapeCSVField(formattedTime),
                this.escapeCSVField(entry.type),
                this.escapeCSVField(entry.details.duration || ''),
                this.escapeCSVField(entry.details.dosage || ''),
                this.escapeCSVField(entry.details.comments || '')
            ];
            
            csvContent += row.join(',') + '\n';
        });
        
        return csvContent;
    }

    escapeCSVField(field) {
        // Handle CSV field escaping - wrap in quotes if contains comma, quote, or newline
        const fieldStr = String(field);
        if (fieldStr.includes(',') || fieldStr.includes('"') || fieldStr.includes('\n')) {
            // Escape quotes by doubling them and wrap in quotes
            return '"' + fieldStr.replace(/"/g, '""') + '"';
        }
        return fieldStr;
    }

    exportData() {
        const data = this.getData();
        
        // Create a structured export object for compatibility
        const exportObject = {
            version: '1.1.0', // Align with app versioning
            exportedAt: new Date().toISOString(),
            source: 'web-app',
            totalEntries: data.length,
            entries: data
        };

        const dataStr = JSON.stringify(exportObject, null, 2);
        const dataBlob = new Blob([dataStr], { type: 'application/json' });
        
        const link = document.createElement('a');
        link.href = URL.createObjectURL(dataBlob);
        link.download = `wellness_log_${new Date().toISOString().split('T')[0]}.json`;
        link.click();
        
        this.showSuccessMessage('Data exported successfully!');
    }

    importData() {
        document.getElementById('file-input').click();
    }

    handleFileImport(e) {
        const file = e.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = (event) => {
            try {
                let importedData = JSON.parse(event.target.result);
                
                // Check for mobile app export format
                if (importedData && typeof importedData === 'object' && !Array.isArray(importedData) && importedData.entries) {
                    this.showSuccessMessage('Mobile app export detected. Importing entries.');
                    importedData = importedData.entries;
                }

                // Validate data structure
                if (!Array.isArray(importedData)) {
                    throw new Error('Invalid data format: Expected an array');
                }

                // Basic validation of each entry
                for (const entry of importedData) {
                    if (!entry.id || !entry.type || !entry.timestamp || !entry.details) {
                        throw new Error('Invalid entry format in imported data');
                    }
                }

                this.saveData(importedData);
                this.renderEntries();
                if (this.currentView === 'calendar') {
                    this.renderCalendar();
                } else if (this.currentView === 'analytics') {
                    this.renderAnalytics();
                }
                this.showSuccessMessage(`Successfully imported ${importedData.length} entries!`);
                
            } catch (error) {
                this.showErrorMessage('Error importing data: ' + error.message);
            }
        };
        
        reader.readAsText(file);
        e.target.value = ''; // Reset file input
    }

    // UI Rendering
    renderEntries() {
        this.allEntries = this.getData();
        this.applyFilters();
    }

    createEntryHTML(entry) {
        const date = new Date(entry.timestamp);
        const formattedDate = date.toLocaleDateString();
        const formattedTime = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        
        const icon = this.getEntryIcon(entry.type);
        const details = this.formatEntryDetails(entry);
        
        return `
            <div class="log-entry">
                <div class="entry-header">
                    <div class="entry-type">
                        <span class="icon">${icon}</span>
                        ${entry.type}
                    </div>
                    <div class="entry-actions">
                        <button class="entry-btn edit-btn" data-id="${entry.id}">Edit</button>
                        <button class="entry-btn delete-btn" data-id="${entry.id}">Delete</button>
                    </div>
                </div>
                <div class="entry-timestamp">${formattedDate} at ${formattedTime}</div>
                <div class="entry-details">${details}</div>
            </div>
        `;
    }

    getEntryIcon(type) {
        const icons = {
            'Exercise': '💪',
            'SVT Episode': '❤️',
            'Medication': '💊'
        };
        return icons[type] || '📝';
    }

    formatEntryDetails(entry) {
        const details = [];
        
        if (entry.details.duration) {
            details.push(`<div class="entry-detail"><strong>Duration:</strong> ${entry.details.duration}</div>`);
        }
        
        if (entry.details.dosage) {
            details.push(`<div class="entry-detail"><strong>Dosage:</strong> ${entry.details.dosage}</div>`);
        }
        
        if (entry.details.comments) {
            details.push(`<div class="entry-detail"><strong>Comments:</strong> ${entry.details.comments}</div>`);
        }
        
        return details.length > 0 ? details.join('') : '<div class="entry-detail">No additional details</div>';
    }

    // Search and Filter Functions
    handleSearch(searchText) {
        this.currentFilters.searchText = searchText.toLowerCase();
        this.applyFilters();
    }

    clearSearch() {
        document.getElementById('search-input').value = '';
        this.currentFilters.searchText = '';
        this.applyFilters();
    }

    handleTypeFilter(type) {
        this.currentFilters.type = type;
        this.applyFilters();
    }

    handleDateRangeFilter(range) {
        this.currentFilters.dateRange = range;
        // Clear custom date range when using quick filters
        if (range) {
            document.getElementById('date-from').value = '';
            document.getElementById('date-to').value = '';
            this.currentFilters.dateFrom = '';
            this.currentFilters.dateTo = '';
        }
        this.applyFilters();
    }

    applyCustomDateRange() {
        const dateFrom = document.getElementById('date-from').value;
        const dateTo = document.getElementById('date-to').value;
        
        if (dateFrom || dateTo) {
            this.currentFilters.dateFrom = dateFrom;
            this.currentFilters.dateTo = dateTo;
            // Clear quick date range filter
            document.getElementById('date-range-filter').value = '';
            this.currentFilters.dateRange = '';
            this.applyFilters();
        }
    }

    clearAllFilters() {
        // Reset all filter controls
        document.getElementById('search-input').value = '';
        document.getElementById('type-filter').value = '';
        document.getElementById('date-range-filter').value = '';
        document.getElementById('date-from').value = '';
        document.getElementById('date-to').value = '';
        
        // Reset filter state
        this.currentFilters = {
            searchText: '',
            type: '',
            dateRange: '',
            dateFrom: '',
            dateTo: ''
        };
        
        this.applyFilters();
    }

    applyFilters() {
        const filteredEntries = this.filterEntries(this.allEntries);
        this.filteredEntries = filteredEntries; // Store for export
        this.renderFilteredEntries(filteredEntries);
        this.updateFilterStatus(filteredEntries.length, this.allEntries.length);
    }

    filterEntries(entries) {
        return entries.filter(entry => {
            // Text search filter
            if (this.currentFilters.searchText) {
                const searchableText = `${entry.type} ${entry.details.comments || ''}`.toLowerCase();
                if (!searchableText.includes(this.currentFilters.searchText)) {
                    return false;
                }
            }

            // Type filter
            if (this.currentFilters.type && entry.type !== this.currentFilters.type) {
                return false;
            }

            // Date range filters
            const entryDate = new Date(entry.timestamp);
            
            // Quick date range filter
            if (this.currentFilters.dateRange) {
                const now = new Date();
                let startDate;
                
                switch (this.currentFilters.dateRange) {
                    case 'today':
                        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                        break;
                    case 'last7':
                        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                        break;
                    case 'last30':
                        startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
                        break;
                    case 'thisMonth':
                        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                        break;
                    case 'lastMonth':
                        const lastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
                        const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0);
                        return entryDate >= lastMonth && entryDate <= lastMonthEnd;
                }
                
                if (startDate && entryDate < startDate) {
                    return false;
                }
            }

            // Custom date range filter
            if (this.currentFilters.dateFrom) {
                const fromDate = new Date(this.currentFilters.dateFrom);
                if (entryDate < fromDate) {
                    return false;
                }
            }
            
            if (this.currentFilters.dateTo) {
                const toDate = new Date(this.currentFilters.dateTo);
                toDate.setHours(23, 59, 59, 999); // Include the entire day
                if (entryDate > toDate) {
                    return false;
                }
            }

            return true;
        });
    }

    updateFilterStatus(filteredCount, totalCount) {
        const statusElement = document.getElementById('filter-status');
        const countElement = document.getElementById('filter-count');
        const filteredExportBtn = document.getElementById('export-filtered-csv');
        
        if (filteredCount === totalCount && !this.hasActiveFilters()) {
            statusElement.style.display = 'none';
            filteredExportBtn.style.display = 'none';
        } else {
            statusElement.style.display = 'block';
            statusElement.className = filteredCount === 0 ? 'filter-status no-results' : 'filter-status';
            
            // Show filtered export button if we have filtered results
            if (filteredCount > 0 && filteredCount < totalCount) {
                filteredExportBtn.style.display = 'inline-flex';
            } else {
                filteredExportBtn.style.display = 'none';
            }
            
            if (filteredCount === 0) {
                countElement.textContent = 'No entries match your filters';
            } else if (filteredCount === totalCount) {
                countElement.textContent = `Showing all ${totalCount} entries`;
            } else {
                countElement.textContent = `Showing ${filteredCount} of ${totalCount} entries`;
            }
        }
    }

    hasActiveFilters() {
        return !!(this.currentFilters.searchText || 
                 this.currentFilters.type || 
                 this.currentFilters.dateRange || 
                 this.currentFilters.dateFrom || 
                 this.currentFilters.dateTo);
    }

    renderFilteredEntries(entries) {
        const container = document.getElementById('entries-container');
        
        if (entries.length === 0) {
            if (this.hasActiveFilters()) {
                container.innerHTML = '<p class="no-entries">No entries match your current filters. Try adjusting your search criteria.</p>';
            } else {
                container.innerHTML = '<p class="no-entries">No entries yet. Start logging your wellness events!</p>';
            }
            return;
        }

        // Sort by timestamp (newest first)
        const sortedEntries = entries.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        container.innerHTML = sortedEntries.map(entry => this.createEntryHTML(entry)).join('');
        
        // Bind event listeners for edit and delete buttons
        container.querySelectorAll('.edit-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const id = e.target.dataset.id;
                this.editEntry(id);
            });
        });
        
        container.querySelectorAll('.delete-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                const id = e.target.dataset.id;
                this.deleteEntry(id);
            });
        });
    }

    // Analytics Functions
    renderAnalytics() {
        const data = this.getData();
        
        // Update all analytics displays
        this.updateAnalyticsCards(data);
        this.updateMonthlyStats(data);
        this.updatePatternStats(data);
    }

    updateAnalyticsCards(data) {
        // Exercise streak
        const exerciseStreak = this.calculateExerciseStreak(data);
        document.getElementById('exercise-streak').textContent = `${exerciseStreak} ${exerciseStreak === 1 ? 'day' : 'days'}`;
        
        // SVT episodes this month
        const svtThisMonth = this.countEntriesThisMonth(data, 'SVT Episode');
        document.getElementById('svt-this-month').textContent = svtThisMonth;
        
        // Medications this month
        const medicationsThisMonth = this.countEntriesThisMonth(data, 'Medication');
        document.getElementById('medications-this-month').textContent = medicationsThisMonth;
        
        // Total entries
        document.getElementById('total-entries').textContent = data.length;
    }

    updateMonthlyStats(data) {
        // Average SVT episodes per month
        const avgSvtMonthly = this.calculateAverageSVTPerMonth(data);
        document.getElementById('avg-svt-monthly').textContent = avgSvtMonthly.toFixed(1);
        
        // Exercise sessions this month
        const exerciseThisMonth = this.countEntriesThisMonth(data, 'Exercise');
        document.getElementById('exercise-this-month').textContent = exerciseThisMonth;
        
        // Most active day of week
        const mostActiveDay = this.getMostActiveDay(data);
        document.getElementById('most-active-day').textContent = mostActiveDay;
        
        // Most common SVT time
        const commonSvtTime = this.getMostCommonSVTTime(data);
        document.getElementById('common-svt-time').textContent = commonSvtTime;
    }

    updatePatternStats(data) {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        
        const recentData = data.filter(entry => new Date(entry.timestamp) >= thirtyDaysAgo);
        
        // SVT Pattern Stats
        const svtEntries = recentData.filter(entry => entry.type === 'SVT Episode');
        document.getElementById('svt-last-30').textContent = svtEntries.length;
        
        const avgDuration = this.calculateAverageSVTDuration(svtEntries);
        document.getElementById('avg-svt-duration').textContent = avgDuration;
        
        const daysSinceLastSVT = this.getDaysSinceLastEntry(data, 'SVT Episode');
        document.getElementById('days-since-svt').textContent = daysSinceLastSVT;
        
        // Exercise Pattern Stats
        const exerciseEntries = recentData.filter(entry => entry.type === 'Exercise');
        document.getElementById('exercise-last-30').textContent = exerciseEntries.length;
        
        const weeklyExerciseAvg = (exerciseEntries.length / 4.3).toFixed(1); // 30 days ≈ 4.3 weeks
        document.getElementById('weekly-exercise-avg').textContent = weeklyExerciseAvg;
        
        const daysSinceLastExercise = this.getDaysSinceLastEntry(data, 'Exercise');
        document.getElementById('days-since-exercise').textContent = daysSinceLastExercise;
    }

    calculateExerciseStreak(data) {
        const exerciseEntries = data
            .filter(entry => entry.type === 'Exercise')
            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        if (exerciseEntries.length === 0) return 0;
        
        const today = new Date();
        const todayStr = this.formatDateKey(today);
        const yesterdayStr = this.formatDateKey(new Date(today.getTime() - 24 * 60 * 60 * 1000));
        
        // Group exercises by date
        const exerciseDates = new Set();
        exerciseEntries.forEach(entry => {
            const date = new Date(entry.timestamp);
            exerciseDates.add(this.formatDateKey(date));
        });
        
        let streak = 0;
        let currentDate = new Date(today);
        
        // Check if today or yesterday has exercise (account for logging delay)
        if (!exerciseDates.has(todayStr) && !exerciseDates.has(yesterdayStr)) {
            return 0;
        }
        
        // Start from yesterday if no exercise today
        if (!exerciseDates.has(todayStr)) {
            currentDate.setDate(currentDate.getDate() - 1);
        }
        
        // Count consecutive days with exercise
        while (exerciseDates.has(this.formatDateKey(currentDate))) {
            streak++;
            currentDate.setDate(currentDate.getDate() - 1);
        }
        
        return streak;
    }

    countEntriesThisMonth(data, type) {
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
        
        return data.filter(entry => {
            const entryDate = new Date(entry.timestamp);
            return entry.type === type && entryDate >= startOfMonth;
        }).length;
    }

    calculateAverageSVTPerMonth(data) {
        const svtEntries = data.filter(entry => entry.type === 'SVT Episode');
        
        if (svtEntries.length === 0) return 0;
        
        // Find date range
        const sortedEntries = svtEntries.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
        const firstEntry = new Date(sortedEntries[0].timestamp);
        const lastEntry = new Date(sortedEntries[sortedEntries.length - 1].timestamp);
        
        // Calculate months between first and last entry
        const monthsDiff = ((lastEntry.getFullYear() - firstEntry.getFullYear()) * 12) + 
                          (lastEntry.getMonth() - firstEntry.getMonth()) + 1;
        
        return svtEntries.length / Math.max(monthsDiff, 1);
    }

    getMostActiveDay(data) {
        const dayCount = {};
        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        
        data.forEach(entry => {
            const date = new Date(entry.timestamp);
            const dayName = dayNames[date.getDay()];
            dayCount[dayName] = (dayCount[dayName] || 0) + 1;
        });
        
        let mostActiveDay = '-';
        let maxCount = 0;
        
        Object.entries(dayCount).forEach(([day, count]) => {
            if (count > maxCount) {
                maxCount = count;
                mostActiveDay = day;
            }
        });
        
        return mostActiveDay;
    }

    getMostCommonSVTTime(data) {
        const svtEntries = data.filter(entry => entry.type === 'SVT Episode');
        
        if (svtEntries.length === 0) return '-';
        
        const timeSlots = {
            'Morning (6-12)': 0,
            'Afternoon (12-18)': 0,
            'Evening (18-24)': 0,
            'Night (0-6)': 0
        };
        
        svtEntries.forEach(entry => {
            const hour = new Date(entry.timestamp).getHours();
            
            if (hour >= 6 && hour < 12) {
                timeSlots['Morning (6-12)']++;
            } else if (hour >= 12 && hour < 18) {
                timeSlots['Afternoon (12-18)']++;
            } else if (hour >= 18 && hour < 24) {
                timeSlots['Evening (18-24)']++;
            } else {
                timeSlots['Night (0-6)']++;
            }
        });
        
        let mostCommonTime = '-';
        let maxCount = 0;
        
        Object.entries(timeSlots).forEach(([timeSlot, count]) => {
            if (count > maxCount) {
                maxCount = count;
                mostCommonTime = timeSlot;
            }
        });
        
        return mostCommonTime;
    }

    calculateAverageSVTDuration(svtEntries) {
        const durationsInMinutes = [];
        
        svtEntries.forEach(entry => {
            if (entry.details.duration) {
                // Extract minutes from duration string (e.g., "3 minutes", "1 minute")
                const match = entry.details.duration.match(/(\d+)/);
                if (match) {
                    durationsInMinutes.push(parseInt(match[1]));
                }
            }
        });
        
        if (durationsInMinutes.length === 0) return '-';
        
        const average = durationsInMinutes.reduce((sum, duration) => sum + duration, 0) / durationsInMinutes.length;
        return `${average.toFixed(1)} min`;
    }

    getDaysSinceLastEntry(data, type) {
        const entries = data
            .filter(entry => entry.type === type)
            .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        if (entries.length === 0) return '-';
        
        const lastEntry = new Date(entries[0].timestamp);
        const now = new Date();
        const diffTime = now.getTime() - lastEntry.getTime();
        const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
        
        if (diffDays === 0) return 'Today';
        if (diffDays === 1) return '1 day';
        return `${diffDays} days`;
    }

    // Mobile UX Enhancements
    initMobileEnhancements() {
        // Detect if user is on mobile
        this.isMobile = window.innerWidth <= 768 || /Android|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        
        if (this.isMobile) {
            // Add mobile-specific class
            document.body.classList.add('mobile-device');
            
            // Handle orientation changes
            window.addEventListener('orientationchange', () => {
                setTimeout(() => {
                    if (this.currentView === 'calendar') {
                        this.renderCalendar();
                    } else if (this.currentView === 'analytics') {
                        this.renderAnalytics();
                    }
                }, 100);
            });
            
            // Improve scroll behavior for modals
            this.setupMobileModalScrolling();
            
            // Add swipe gesture for calendar navigation on mobile
            this.setupCalendarSwipeGestures();
        }
        
        // Handle window resize for responsive updates
        window.addEventListener('resize', this.debounce(() => {
            this.isMobile = window.innerWidth <= 768;
            if (this.currentView === 'calendar') {
                this.renderCalendar();
            }
        }, 250));
    }

    setupMobileModalScrolling() {
        // Prevent background scrolling when modal is open
        const originalShowEditModal = this.showEditModal.bind(this);
        const originalCloseEditModal = this.closeEditModal.bind(this);
        const originalShowConfirmModal = this.showConfirmModal.bind(this);
        const originalCloseConfirmModal = this.closeConfirmModal.bind(this);
        const originalShowDayModal = this.showDayModal.bind(this);
        const originalCloseDayModal = this.closeDayModal.bind(this);

        this.showEditModal = () => {
            originalShowEditModal();
            if (this.isMobile) {
                document.body.style.position = 'fixed';
                document.body.style.width = '100%';
            }
        };

        this.closeEditModal = () => {
            originalCloseEditModal();
            if (this.isMobile) {
                document.body.style.position = '';
                document.body.style.width = '';
            }
        };

        this.showConfirmModal = () => {
            originalShowConfirmModal();
            if (this.isMobile) {
                document.body.style.position = 'fixed';
                document.body.style.width = '100%';
            }
        };

        this.closeConfirmModal = () => {
            originalCloseConfirmModal();
            if (this.isMobile) {
                document.body.style.position = '';
                document.body.style.width = '';
            }
        };

        // Override showDayModal to include mobile scroll prevention
        this.showDayModal = (date, entries) => {
            originalShowDayModal(date, entries);
            if (this.isMobile) {
                document.body.style.position = 'fixed';
                document.body.style.width = '100%';
            }
        };

        this.closeDayModal = () => {
            originalCloseDayModal();
            if (this.isMobile) {
                document.body.style.position = '';
                document.body.style.width = '';
            }
        };
    }

    setupCalendarSwipeGestures() {
        if (!this.isMobile) return;

        const calendarGrid = document.getElementById('calendar-grid');
        let startX = 0;
        let endX = 0;
        const minSwipeDistance = 50;

        calendarGrid.addEventListener('touchstart', (e) => {
            startX = e.touches[0].clientX;
        }, { passive: true });

        calendarGrid.addEventListener('touchend', (e) => {
            endX = e.changedTouches[0].clientX;
            const distance = Math.abs(endX - startX);
            
            if (distance > minSwipeDistance) {
                if (endX < startX) {
                    // Swipe left - next month
                    this.navigateMonth(1);
                } else {
                    // Swipe right - previous month
                    this.navigateMonth(-1);
                }
            }
        }, { passive: true });
    }

    // Utility function for debouncing resize events
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }

    // ...existing code...
}

// Add CSS animations for messages
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Initialize the application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new WellnessLogger();
});