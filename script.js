// Personal Wellness Logger - Main JavaScript File

class WellnessLogger {
    constructor() {
        this.storageKey = 'wellness_log_data';
        this.currentEditId = null;
        this.currentDeleteId = null;
        this.currentView = 'list';
        this.currentDate = new Date();
        this.init();
    }

    init() {
        this.bindEvents();
        this.renderEntries();
        this.renderCalendar();
    }

    bindEvents() {
        // View toggle buttons
        document.getElementById('list-view-btn').addEventListener('click', () => this.switchView('list'));
        document.getElementById('calendar-view-btn').addEventListener('click', () => this.switchView('calendar'));

        // Quick log buttons
        document.getElementById('log-exercise').addEventListener('click', () => this.logExercise());
        document.getElementById('log-svt').addEventListener('click', () => this.logSVTEpisode());
        document.getElementById('log-medication').addEventListener('click', () => this.logMedication());

        // Data management buttons
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
        
        // Show/hide sections
        document.getElementById('list-section').style.display = view === 'list' ? 'block' : 'none';
        document.getElementById('calendar-section').style.display = view === 'calendar' ? 'block' : 'none';
        
        if (view === 'calendar') {
            this.renderCalendar();
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
        }
        this.closeEditModal();
        this.showSuccessMessage('Entry updated successfully!');
    }

    // Data Import/Export
    exportData() {
        const data = this.getData();
        const dataStr = JSON.stringify(data, null, 2);
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
                const importedData = JSON.parse(event.target.result);
                
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
        const data = this.getData();
        const container = document.getElementById('entries-container');
        
        if (data.length === 0) {
            container.innerHTML = '<p class="no-entries">No entries yet. Start logging your wellness events!</p>';
            return;
        }

        // Sort by timestamp (newest first)
        const sortedData = data.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
        
        container.innerHTML = sortedData.map(entry => this.createEntryHTML(entry)).join('');
        
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

    // Utility Functions
    showSuccessMessage(message) {
        this.showMessage(message, 'success');
    }

    showErrorMessage(message) {
        this.showMessage(message, 'error');
    }

    showMessage(message, type) {
        // Create a temporary message element
        const messageEl = document.createElement('div');
        messageEl.textContent = message;
        messageEl.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 12px 20px;
            border-radius: 6px;
            color: white;
            font-weight: 500;
            z-index: 10000;
            animation: slideIn 0.3s ease;
            background: ${type === 'success' ? '#48bb78' : '#e53e3e'};
        `;
        
        document.body.appendChild(messageEl);
        
        // Remove after 3 seconds
        setTimeout(() => {
            messageEl.style.animation = 'slideOut 0.3s ease';
            setTimeout(() => {
                if (messageEl.parentNode) {
                    messageEl.parentNode.removeChild(messageEl);
                }
            }, 300);
        }, 3000);
    }
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