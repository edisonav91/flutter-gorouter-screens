import 'package:flutter/material.dart';

void main() {
  // Punto de entrada de la aplicacion.
  // Flutter comienza aqui y renderiza el widget raiz que contiene toda la UI.
  runApp(const StudySprintApp());
}

class StudySprintApp extends StatelessWidget {
  const StudySprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp define la configuracion global de la app:
    // titulo, tema visual, comportamiento general y pantalla inicial.
    // Se usa un tema centralizado para mantener coherencia visual en todas
    // las secciones sin repetir estilos manualmente.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Sprint',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B6E4F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
        useMaterial3: true,
      ),
      home: const StudyHomePage(),
    );
  }
}

enum TaskPriority { low, medium, high }

enum TaskFilter { all, pending, completed }

class StudyTask {
  // Este modelo representa una tarea de estudio dentro de la aplicacion.
  // Tener una clase de dominio separada ayuda a organizar mejor los datos
  // y evita manejar mapas o variables sueltas dentro de la interfaz.
  StudyTask({
    required this.title,
    required this.subject,
    required this.durationInMinutes,
    required this.priority,
    required this.deadline,
    this.isCompleted = false,
  });

  final String title;
  final String subject;
  final int durationInMinutes;
  final TaskPriority priority;
  final DateTime deadline;
  bool isCompleted;
}

class StudyHomePage extends StatefulWidget {
  const StudyHomePage({super.key});

  @override
  State<StudyHomePage> createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  // La lista de tareas es la fuente principal de datos de la aplicacion.
  // Desde esta estructura se calculan filtros, conteos y progreso general.
  // Aqui se demuestra manejo de estado local con setState sin paquetes
  // externos, algo util para practicas pequenas o apps sencillas.
  final List<StudyTask> _tasks = [
    StudyTask(
      title: 'Repasar widgets basicos',
      subject: 'Flutter',
      durationInMinutes: 45,
      priority: TaskPriority.high,
      deadline: DateTime.now().add(const Duration(days: 1)),
    ),
    StudyTask(
      title: 'Practicar Dart con listas',
      subject: 'Programacion',
      durationInMinutes: 30,
      priority: TaskPriority.medium,
      deadline: DateTime.now().add(const Duration(days: 2)),
    ),
    StudyTask(
      title: 'Leer sobre Material 3',
      subject: 'Diseno UI',
      durationInMinutes: 20,
      priority: TaskPriority.low,
      deadline: DateTime.now().add(const Duration(days: 3)),
      isCompleted: true,
    ),
  ];

  int _selectedTab = 0;
  TaskFilter _selectedFilter = TaskFilter.all;

  List<StudyTask> get _filteredTasks {
    // El filtrado no se guarda en otra lista permanente.
    // Se calcula cada vez a partir de _tasks para mantener una sola fuente
    // de verdad y evitar inconsistencias entre tareas, filtros y resumen.
    switch (_selectedFilter) {
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  int get _completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;

  int get _totalMinutes =>
      _tasks.fold(0, (sum, task) => sum + task.durationInMinutes);

  double get _progressValue {
    if (_tasks.isEmpty) {
      return 0;
    }
    // El progreso se obtiene dividiendo tareas completadas sobre el total.
    // No se guarda como una variable adicional porque seria redundante:
    // si cambia una tarea, el valor se recalcula automaticamente y se evita
    // que el resumen muestre datos desactualizados.
    return _completedTasksCount / _tasks.length;
  }

  void _toggleTask(StudyTask task, bool isCompleted) {
    // Cuando una tarea cambia de estado, se actualiza directamente el modelo
    // y setState fuerza la reconstruccion de la interfaz.
    // Eso sincroniza de inmediato la lista, los filtros y el resumen.
    setState(() {
      task.isCompleted = isCompleted;
    });
  }

  void _addTask(StudyTask task) {
    setState(() {
      _tasks.add(task);
      // Despues de crear una tarea, la app vuelve al listado principal.
      // Asi el usuario recibe confirmacion visual inmediata de que el
      // registro fue agregado correctamente.
      _selectedTab = 0;
      _selectedFilter = TaskFilter.all;
    });

    // SnackBar se usa como retroalimentacion breve sin interrumpir el flujo.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarea "${task.title}" agregada correctamente.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // La app se divide en tres vistas principales:
    // listado de tareas, resumen y formulario de registro.
    // Se organizan en una lista para alternarlas usando el indice
    // seleccionado en la barra de navegacion inferior.
    final pages = [
      _TasksView(
        tasks: _filteredTasks,
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        onTaskChanged: _toggleTask,
      ),
      _SummaryView(
        totalTasks: _tasks.length,
        completedTasks: _completedTasksCount,
        totalMinutes: _totalMinutes,
        progressValue: _progressValue,
      ),
      _AddTaskView(
        onTaskCreated: _addTask,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Sprint'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          // AnimatedSwitcher agrega una transicion suave al cambiar de seccion.
          // Esto mejora la experiencia visual sin necesidad de rutas separadas
          // ni una navegacion mas compleja.
          duration: const Duration(milliseconds: 250),
          child: pages[_selectedTab],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Tareas',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_rounded),
            label: 'Resumen',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline_rounded),
            label: 'Nueva',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
      ),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView({
    required this.tasks,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onTaskChanged,
  });

  final List<StudyTask> tasks;
  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onFilterChanged;
  final void Function(StudyTask task, bool isCompleted) onTaskChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // LayoutBuilder permite leer el ancho disponible y adaptar la UI.
        // En pantallas grandes se aumenta el padding horizontal para que el
        // contenido no quede demasiado extendido y sea mas legible.
        final horizontalPadding = constraints.maxWidth > 700 ? 32.0 : 16.0;

        return ListView(
          key: const ValueKey('tasks-view'),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            24,
          ),
          children: [
            const _HeroCard(),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskFilter.values.map((filter) {
                return ChoiceChip(
                  label: Text(_taskFilterLabel(filter)),
                  selected: selectedFilter == filter,
                  onSelected: (_) => onFilterChanged(filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (tasks.isEmpty)
              const _EmptyState()
            else
              ...tasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TaskCard(
                    task: task,
                    onChanged: (value) => onTaskChanged(task, value),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.totalTasks,
    required this.completedTasks,
    required this.totalMinutes,
    required this.progressValue,
  });

  final int totalTasks;
  final int completedTasks;
  final int totalMinutes;
  final double progressValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        // Las metricas se encapsulan en widgets reutilizables para mantener
        // una estructura modular. Esta separacion facilita la lectura del
        // codigo, su mantenimiento y su explicacion en la entrega.
        final cards = [
          _MetricCard(
            title: 'Tareas creadas',
            value: '$totalTasks',
            icon: Icons.task_alt_rounded,
            color: const Color(0xFF2D6A4F),
          ),
          _MetricCard(
            title: 'Tareas completadas',
            value: '$completedTasks',
            icon: Icons.verified_rounded,
            color: const Color(0xFF40916C),
          ),
          _MetricCard(
            title: 'Tiempo planeado',
            value: '$totalMinutes min',
            icon: Icons.timer_outlined,
            color: const Color(0xFF1D3557),
          ),
        ];

        return ListView(
          key: const ValueKey('summary-view'),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B6E4F), Color(0xFF95D5B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso general',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: progressValue,
                      backgroundColor: Colors.white30,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(progressValue * 100).round()}% completado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (isWide)
              Row(
                children: [
                  for (final card in cards)
                    Expanded(
                      child: Padding(
                        // En pantallas anchas las metricas se muestran en fila
                        // para aprovechar mejor el espacio horizontal.
                        padding: const EdgeInsets.only(right: 12),
                        child: card,
                      ),
                    ),
                ],
              )
            else
              ...cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: card,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AddTaskView extends StatefulWidget {
  const _AddTaskView({required this.onTaskCreated});

  final ValueChanged<StudyTask> onTaskCreated;

  @override
  State<_AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<_AddTaskView> {
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _durationController = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Los controladores se liberan manualmente cuando este widget se destruye.
    // Esto evita fugas de memoria y es una buena practica al trabajar con
    // TextEditingController en formularios.
    _titleController.dispose();
    _subjectController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    // showDatePicker abre el selector de fecha de Material Design.
    // Se evita pedir la fecha como texto libre para reducir errores de captura
    // y mejorar la experiencia del usuario.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    final subject = _subjectController.text.trim();
    final minutes = int.tryParse(_durationController.text.trim());

    if (title.isEmpty ||
        subject.isEmpty ||
        minutes == null ||
        minutes <= 0 ||
        _selectedDate == null) {
      // Antes de crear una tarea se validan todos los campos.
      // La idea es impedir que el estado principal reciba datos incompletos
      // o invalidos, como una duracion vacia o una fecha no seleccionada.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos con datos validos.'),
        ),
      );
      return;
    }

    widget.onTaskCreated(
      // Solo despues de validar se construye el objeto StudyTask.
      // De esta manera el widget padre recibe una entidad consistente.
      StudyTask(
        title: title,
        subject: subject,
        durationInMinutes: minutes,
        priority: _priority,
        deadline: _selectedDate!,
      ),
    );

    _titleController.clear();
    _subjectController.clear();
    _durationController.clear();

    setState(() {
      // Luego de guardar, el formulario vuelve a su estado inicial.
      // Esto deja la vista lista para registrar otra tarea sin arrastrar
      // datos de la sesion anterior.
      _priority = TaskPriority.medium;
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('add-view'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nueva sesion de estudio',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Registra una tarea y organiza mejor tu tiempo.',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titulo de la tarea',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Materia o tema',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                // Se solicita teclado numerico para orientar al usuario
                // a ingresar solo la duracion en minutos.
                decoration: const InputDecoration(
                  labelText: 'Duracion estimada en minutos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem<TaskPriority>(
                    value: priority,
                    child: Text(_taskPriorityLabel(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _priority = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  _selectedDate == null
                      ? 'Seleccionar fecha limite'
                      : 'Fecha: ${_formatDate(_selectedDate!)}',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar tarea'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    // Esta tarjeta funciona como encabezado visual de la pantalla principal.
    // Sirve para comunicar el objetivo de la app y reforzar la identidad
    // grafica sin recurrir a una pantalla extra de bienvenida.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organiza tu estudio con enfoque',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Crea tareas, controla prioridades y mide tu avance en una sola app.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onChanged,
  });

  final StudyTask task;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.subject,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    // Los chips muestran informacion clave de forma compacta:
                    // duracion, prioridad y fecha limite. Asi se evita una
                    // interfaz recargada y cada tarea sigue siendo facil de leer.
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.timer, size: 18),
                        label: Text('${task.durationInMinutes} min'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.flag_outlined, size: 18),
                        label: Text(_taskPriorityLabel(task.priority)),
                      ),
                      Chip(
                        avatar: const Icon(Icons.event_outlined, size: 18),
                        label: Text(_formatDate(task.deadline)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              // El cambio de estado no se resuelve aqui localmente.
              // Se delega al widget padre para que toda la app quede
              // sincronizada desde un unico punto de actualizacion.
              value: task.isCompleted,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 54,
            color: Color(0xFF52796F),
          ),
          SizedBox(height: 12),
          Text(
            'No hay tareas en este filtro.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Agrega una nueva sesion de estudio o cambia el filtro actual.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _taskPriorityLabel(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.low:
      return 'Baja';
    case TaskPriority.medium:
      return 'Media';
    case TaskPriority.high:
      return 'Alta';
  }
}

String _taskFilterLabel(TaskFilter filter) {
  switch (filter) {
    case TaskFilter.all:
      return 'Todas';
    case TaskFilter.pending:
      return 'Pendientes';
    case TaskFilter.completed:
      return 'Completadas';
  }
}

String _formatDate(DateTime date) {
  // La fecha se formatea manualmente para mantener el ejemplo pequeno.
  // Se evita agregar dependencias externas porque el foco de la practica
  // esta en widgets, estado local, formularios y navegacion interna.
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
