export const CATEGORIES = [
  {
    id: "animo",
    name: "Animo",
    symbol: "SUN",
    color: "#D9903D",
    softColor: "#3C2418",
    description: "Impulso para empezar el dia con claridad."
  },
  {
    id: "foco",
    name: "Foco",
    symbol: "EYE",
    color: "#CFA76C",
    softColor: "#252A22",
    description: "Una pregunta para ordenar tu energia."
  },
  {
    id: "calma",
    name: "Calma",
    symbol: "LOTUS",
    color: "#74A8A0",
    softColor: "#173037",
    description: "Presencia para volver al centro."
  },
  {
    id: "disciplina",
    name: "Disciplina",
    symbol: "MOUNT",
    color: "#8AA36D",
    softColor: "#23301E",
    description: "Constancia suave para avanzar."
  },
  {
    id: "autoestima",
    name: "Autoestima",
    symbol: "HEART",
    color: "#D48B9B",
    softColor: "#3B2133",
    description: "Una mirada amable hacia ti."
  },
  {
    id: "gratitud",
    name: "Gratitud",
    symbol: "HANDS",
    color: "#C26B80",
    softColor: "#3A1D2C",
    description: "Reconocer lo que ya sostiene tu camino."
  },
  {
    id: "valentia",
    name: "Valentia",
    symbol: "LION",
    color: "#B97834",
    softColor: "#35200F",
    description: "Coraje sereno para cruzar una puerta."
  },
  {
    id: "habitos",
    name: "Habitos",
    symbol: "PLANT",
    color: "#8FB477",
    softColor: "#1E3122",
    description: "Pequenas acciones que cambian el clima interior."
  },
  {
    id: "creatividad",
    name: "Creatividad",
    symbol: "MOON",
    color: "#D9A24F",
    softColor: "#1B223D",
    description: "Una chispa nueva para mirar distinto."
  },
  {
    id: "resiliencia",
    name: "Resiliencia",
    symbol: "WAVES",
    color: "#7EA7B7",
    softColor: "#17303B",
    description: "Elasticidad para seguir sin endurecerte."
  },
  {
    id: "relaciones",
    name: "Relaciones",
    symbol: "TWO",
    color: "#B87DB0",
    softColor: "#30213C",
    description: "Verdad, escucha y limites sanos."
  },
  {
    id: "energia",
    name: "Energia",
    symbol: "STAR",
    color: "#D7B36A",
    softColor: "#2D2818",
    description: "Donde poner luz sin agotarte."
  }
];

export const TAROT_CARDS = [
  {
    id: "animo-01",
    category: "animo",
    title: "El Alba Interior",
    message: "Hoy no necesitas resolver toda tu vida. Elige un gesto luminoso y deja que el resto del dia se ordene a partir de ahi.",
    prompt: "Que accion pequena haria mas amable este comienzo?"
  },
  {
    id: "animo-02",
    category: "animo",
    title: "La Llama Firme",
    message: "Tu energia vuelve cuando dejas de perseguir aprobacion. Haz lo que sabes que te devuelve presencia.",
    prompt: "Donde estas entregando fuerza que necesitas recuperar?"
  },
  {
    id: "animo-03",
    category: "animo",
    title: "El Sol Bajo",
    message: "Incluso una luz discreta cambia una habitacion. No subestimes el valor de aparecer con honestidad.",
    prompt: "Que parte de ti merece ser vista hoy?"
  },
  {
    id: "foco-01",
    category: "foco",
    title: "El Ojo Sereno",
    message: "La claridad no llega por hacer mas, sino por quitar ruido. Escoge una prioridad y protege su espacio.",
    prompt: "Que tarea merece tu mejor hora?"
  },
  {
    id: "foco-02",
    category: "foco",
    title: "La Aguja Dorada",
    message: "Tu atencion es una herramienta sagrada. Si la dispersas, todo pesa; si la diriges, algo importante avanza.",
    prompt: "Que distraccion puedes cerrar durante una hora?"
  },
  {
    id: "foco-03",
    category: "foco",
    title: "La Mesa Clara",
    message: "Antes de moverte, ordena el campo. Una decision limpia vale mas que diez impulsos urgentes.",
    prompt: "Que dato falta para decidir sin forzarte?"
  },
  {
    id: "calma-01",
    category: "calma",
    title: "El Cuenco Quieto",
    message: "No confundas paz con pasividad. La calma tambien es una forma de direccion.",
    prompt: "Que puedes hacer mas despacio sin perder eficacia?"
  },
  {
    id: "calma-02",
    category: "calma",
    title: "La Flor Nocturna",
    message: "Tu cuerpo sabe antes que tu mente cuando algo se estrecha. Escucharlo hoy te ahorra una pelea interna.",
    prompt: "Que sensacion corporal pide atencion?"
  },
  {
    id: "calma-03",
    category: "calma",
    title: "La Bruma Azul",
    message: "Permite que algunas respuestas sigan sin forma. Lo que necesita madurar no mejora con presion.",
    prompt: "Que pregunta puedes dejar respirar?"
  },
  {
    id: "disciplina-01",
    category: "disciplina",
    title: "La Montana Paciente",
    message: "El avance real hoy sera repetible. Hazlo tan sencillo que puedas volver manana.",
    prompt: "Cual es la version minima de tu compromiso?"
  },
  {
    id: "disciplina-02",
    category: "disciplina",
    title: "La Puerta Estrecha",
    message: "Un limite bien puesto libera mas energia de la que quita. Di no a una cosa para decir si a tu camino.",
    prompt: "Que no protege tu si mas importante?"
  },
  {
    id: "disciplina-03",
    category: "disciplina",
    title: "El Hilo Constante",
    message: "La magia se parece mucho a la repeticion cuando nadie mira. Cumple contigo en pequeno.",
    prompt: "Que gesto diario esta pidiendo continuidad?"
  },
  {
    id: "autoestima-01",
    category: "autoestima",
    title: "El Espejo Noble",
    message: "No necesitas hablarte con dureza para mejorar. La verdad puede ser precisa y amable al mismo tiempo.",
    prompt: "Que frase te dirias si fueras tu mejor aliada?"
  },
  {
    id: "autoestima-02",
    category: "autoestima",
    title: "El Corazon Coronado",
    message: "Tu valor no sube ni baja con la respuesta de nadie. Vuelve a tu centro antes de interpretar senales externas.",
    prompt: "Que validacion estas esperando de fuera?"
  },
  {
    id: "autoestima-03",
    category: "autoestima",
    title: "La Casa Propia",
    message: "Habitarte bien es una practica. Hoy cuida una frontera, un descanso o una necesidad concreta.",
    prompt: "Que parte de ti necesita hogar?"
  },
  {
    id: "gratitud-01",
    category: "gratitud",
    title: "Las Manos Abiertas",
    message: "Agradecer no niega lo dificil. Solo recuerda que tambien hay suelo bajo tus pies.",
    prompt: "Que apoyo silencioso esta presente hoy?"
  },
  {
    id: "gratitud-02",
    category: "gratitud",
    title: "La Copa Llena",
    message: "Mira lo que ya llego antes de pedir otra senal. La abundancia empieza por reconocer.",
    prompt: "Que cosa pequena merece ser celebrada?"
  },
  {
    id: "gratitud-03",
    category: "gratitud",
    title: "El Pan Compartido",
    message: "La gratitud crece cuando circula. Nombra algo bueno ante alguien que tambien necesite luz.",
    prompt: "A quien puedes agradecer con claridad?"
  },
  {
    id: "valentia-01",
    category: "valentia",
    title: "El Leon Dorado",
    message: "La valentia no siempre ruge. A veces se sienta derecha y dice la verdad sin atacar.",
    prompt: "Que verdad puedes expresar con firmeza tranquila?"
  },
  {
    id: "valentia-02",
    category: "valentia",
    title: "La Antorcha",
    message: "No esperes sentir seguridad total para dar el paso. Pide evidencia suficiente, no certeza absoluta.",
    prompt: "Que paso seria valiente y responsable a la vez?"
  },
  {
    id: "valentia-03",
    category: "valentia",
    title: "El Umbral",
    message: "Algo nuevo te pide dejar una identidad antigua. No tienes que traicionarte para crecer.",
    prompt: "Que version vieja de ti ya cumplio su funcion?"
  },
  {
    id: "habitos-01",
    category: "habitos",
    title: "La Semilla",
    message: "Lo que repites te disena. Siembra una accion tan concreta que el dia no pueda borrarla.",
    prompt: "Que habito de cinco minutos tendria impacto real?"
  },
  {
    id: "habitos-02",
    category: "habitos",
    title: "El Jardin Interno",
    message: "No todo crece al mismo ritmo. Riega lo importante antes de revisar lo que aun no florece.",
    prompt: "Que merece cuidado antes que evaluacion?"
  },
  {
    id: "habitos-03",
    category: "habitos",
    title: "La Llave Simple",
    message: "La constancia se protege con friccion baja. Haz facil lo que quieres repetir.",
    prompt: "Que obstaculo practico puedes retirar hoy?"
  },
  {
    id: "creatividad-01",
    category: "creatividad",
    title: "La Luna Creadora",
    message: "No descartes la idea rara demasiado pronto. A veces la intuicion llega vestida de juego.",
    prompt: "Que probarias si no tuvieras que hacerlo perfecto?"
  },
  {
    id: "creatividad-02",
    category: "creatividad",
    title: "La Chispa",
    message: "Cambia de herramienta, de lugar o de orden. Una variacion pequena puede abrir una puerta grande.",
    prompt: "Que puedes mirar desde otro angulo?"
  },
  {
    id: "creatividad-03",
    category: "creatividad",
    title: "El Taller Secreto",
    message: "Protege una parte de tu proceso de la opinion temprana. Algunas cosas necesitan intimidad antes de mostrarse.",
    prompt: "Que idea necesita mas silencio?"
  },
  {
    id: "resiliencia-01",
    category: "resiliencia",
    title: "Las Olas",
    message: "No tienes que ser rigida para ser fuerte. Adapta la forma sin abandonar la direccion.",
    prompt: "Donde puedes ceder forma y conservar fondo?"
  },
  {
    id: "resiliencia-02",
    category: "resiliencia",
    title: "La Piedra Tibia",
    message: "Has atravesado mas de lo que recuerdas en los dias dificiles. Usa tu historial como prueba, no como carga.",
    prompt: "Que experiencia pasada demuestra tu capacidad?"
  },
  {
    id: "resiliencia-03",
    category: "resiliencia",
    title: "El Puente",
    message: "No intentes saltar de herida a solucion. Construye el siguiente tramo con algo que puedas sostener.",
    prompt: "Cual es el siguiente paso honesto?"
  },
  {
    id: "relaciones-01",
    category: "relaciones",
    title: "Las Dos Velas",
    message: "La cercania sana no exige apagarte. Una relacion real deja espacio para dos luces.",
    prompt: "Donde necesitas mas reciprocidad?"
  },
  {
    id: "relaciones-02",
    category: "relaciones",
    title: "El Nudo Suelto",
    message: "No todo conflicto pide intensidad. A veces una pregunta clara deshace mas que una defensa larga.",
    prompt: "Que pregunta honesta puede abrir conversacion?"
  },
  {
    id: "relaciones-03",
    category: "relaciones",
    title: "El Limite Dorado",
    message: "Poner un limite no destruye el vinculo correcto. Solo revela si puede respirar con verdad.",
    prompt: "Que limite seria justo para ambas partes?"
  },
  {
    id: "energia-01",
    category: "energia",
    title: "La Estrella Guia",
    message: "No todo lo brillante merece tu energia. Sigue lo que ilumina sin vaciarte.",
    prompt: "Que entusiasmo se siente nutritivo, no urgente?"
  },
  {
    id: "energia-02",
    category: "energia",
    title: "El Circulo Solar",
    message: "Tu ritmo importa. Alterna expansion y descanso si quieres que la luz dure.",
    prompt: "Que pausa haria sostenible tu intensidad?"
  },
  {
    id: "energia-03",
    category: "energia",
    title: "El Fuego Azul",
    message: "Hay fuerza en la precision. Pon tu energia donde haya verdad, no donde haya ruido.",
    prompt: "Que conversacion, tarea o deseo merece tu mejor fuego?"
  }
];
