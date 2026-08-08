import AsyncStorage from "@react-native-async-storage/async-storage";
import * as Notifications from "expo-notifications";
import { StatusBar } from "expo-status-bar";
import { useEffect, useMemo, useState } from "react";
import {
  Alert,
  FlatList,
  Pressable,
  SafeAreaView,
  ScrollView,
  Share,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View
} from "react-native";

import { CATEGORIES, TAROT_CARDS } from "./data/tarot";

const STORAGE_KEY = "tarot-cotidiano-state";
const DAILY_NOTIFICATION_ID_KEY = "tarot-cotidiano-daily-notification-id";
const DEFAULT_STATE = {
  savedCards: [],
  selectedCategory: "animo",
  reminderEnabled: false,
  reminderTime: "08:00"
};

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldPlaySound: false,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true
  })
});

export default function App() {
  const [state, setState] = useState(DEFAULT_STATE);
  const [activeTab, setActiveTab] = useState("today");
  const [revealed, setRevealed] = useState(false);
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY)
      .then((raw) => {
        if (raw) setState({ ...DEFAULT_STATE, ...JSON.parse(raw) });
      })
      .finally(() => setLoaded(true));
  }, []);

  useEffect(() => {
    if (!loaded) return;
    AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }, [loaded, state]);

  const todayCard = useMemo(() => getCardForToday(), []);
  const selectedCategory = getCategory(state.selectedCategory);
  const savedSet = useMemo(() => new Set(state.savedCards), [state.savedCards]);
  const visibleCards = useMemo(
    () => TAROT_CARDS.filter((card) => card.category === state.selectedCategory),
    [state.selectedCategory]
  );
  const savedCards = useMemo(
    () => state.savedCards.map((id) => TAROT_CARDS.find((card) => card.id === id)).filter(Boolean),
    [state.savedCards]
  );

  function updateState(patch) {
    setState((current) => ({ ...current, ...patch }));
  }

  function toggleSaved(id) {
    setState((current) => {
      const exists = current.savedCards.includes(id);
      return {
        ...current,
        savedCards: exists
          ? current.savedCards.filter((cardId) => cardId !== id)
          : [id, ...current.savedCards]
      };
    });
  }

  async function shareCard(card) {
    await Share.share({
      message: `${card.title}\n\n${card.message}\n\nTarot Cotidiano`
    });
  }

  async function saveReminder(enabled = state.reminderEnabled, time = state.reminderTime) {
    const cleanTime = normalizeTime(time);
    if (enabled) {
      const permission = await Notifications.requestPermissionsAsync();
      if (!permission.granted) {
        Alert.alert("Notificaciones", "Activa las notificaciones para recibir tu carta diaria.");
        updateState({ reminderEnabled: false, reminderTime: cleanTime });
        return;
      }

      await scheduleDailyReminder(cleanTime);
      updateState({ reminderEnabled: true, reminderTime: cleanTime });
      Alert.alert("Listo", `Recibiras tu carta cada dia a las ${cleanTime}.`);
      return;
    }

    await cancelDailyReminder();
    updateState({ reminderEnabled: false, reminderTime: cleanTime });
  }

  async function sendTestNotification() {
    const permission = await Notifications.requestPermissionsAsync();
    if (!permission.granted) {
      Alert.alert("Notificaciones", "Primero permite las notificaciones.");
      return;
    }

    await Notifications.scheduleNotificationAsync({
      content: {
        title: "Tu carta diaria te espera",
        body: todayCard.title
      },
      trigger: null
    });
  }

  function renderToday() {
    const category = getCategory(todayCard.category);
    return (
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <TopBar title="Tarot Cotidiano" subtitle={formatToday()} />

        <View style={styles.dailyIntro}>
          <Text style={styles.kicker}>Tu carta diaria</Text>
          <Text style={styles.dailyTitle}>{revealed ? todayCard.title : "Desliza tu intuicion"}</Text>
          <Text style={styles.dailySubtitle}>
            {revealed ? todayCard.prompt : "Toca la carta para revelar el mensaje que acompana tu dia."}
          </Text>
        </View>

        <Pressable
          style={[styles.deckStage, { borderColor: category.color }]}
          onPress={() => setRevealed(true)}
        >
          <View style={[styles.aura, { backgroundColor: category.color }]} />
          {revealed ? <TarotFace card={todayCard} /> : <TarotBack />}
        </Pressable>

        {revealed && (
          <View style={styles.messagePanel}>
            <Text style={[styles.messageCategory, { color: category.color }]}>{category.name}</Text>
            <Text style={styles.messageText}>{todayCard.message}</Text>
            <View style={styles.actionRow}>
              <Pressable style={styles.primaryButton} onPress={() => toggleSaved(todayCard.id)}>
                <Text style={styles.primaryButtonText}>
                  {savedSet.has(todayCard.id) ? "Guardada" : "Guardar"}
                </Text>
              </Pressable>
              <Pressable style={styles.secondaryButton} onPress={() => shareCard(todayCard)}>
                <Text style={styles.secondaryButtonText}>Compartir</Text>
              </Pressable>
            </View>
          </View>
        )}
      </ScrollView>
    );
  }

  function renderCategories() {
    return (
      <View style={styles.screen}>
        <TopBar title="Categorias" subtitle={selectedCategory.description} compact />
        <FlatList
          data={CATEGORIES}
          keyExtractor={(item) => item.id}
          numColumns={3}
          columnWrapperStyle={styles.categoryRow}
          contentContainerStyle={styles.categoryGrid}
          showsVerticalScrollIndicator={false}
          renderItem={({ item }) => {
            const active = item.id === state.selectedCategory;
            return (
              <Pressable
                style={[
                  styles.categoryCard,
                  { backgroundColor: item.softColor, borderColor: active ? item.color : "rgba(220, 179, 105, 0.24)" }
                ]}
                onPress={() => updateState({ selectedCategory: item.id })}
              >
                <Symbol name={item.symbol} color={item.color} size={30} />
                <Text style={styles.categoryName}>{item.name}</Text>
              </Pressable>
            );
          }}
        />

        <Text style={styles.sectionTitle}>Cartas de {selectedCategory.name}</Text>
        <FlatList
          data={visibleCards}
          keyExtractor={(item) => item.id}
          horizontal
          contentContainerStyle={styles.horizontalCards}
          showsHorizontalScrollIndicator={false}
          renderItem={({ item }) => (
            <MiniCard
              card={item}
              saved={savedSet.has(item.id)}
              onSave={() => toggleSaved(item.id)}
              onShare={() => shareCard(item)}
            />
          )}
        />
      </View>
    );
  }

  function renderSaved() {
    return (
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <TopBar title="Guardadas" subtitle="Mensajes para volver a consultar" />
        {savedCards.length === 0 ? (
          <View style={styles.emptyState}>
            <Symbol name="MOON" color="#D7B36A" size={54} />
            <Text style={styles.emptyTitle}>Aun no hay cartas guardadas</Text>
            <Text style={styles.emptyText}>Revela tu carta diaria o explora categorias para conservar los mensajes que quieras recordar.</Text>
          </View>
        ) : (
          savedCards.map((card) => (
            <SavedCard
              key={card.id}
              card={card}
              onRemove={() => toggleSaved(card.id)}
              onShare={() => shareCard(card)}
            />
          ))
        )}
      </ScrollView>
    );
  }

  function renderSettings() {
    return (
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <TopBar title="Ajustes" subtitle="Ritual diario y notificaciones" />

        <View style={styles.settingsPanel}>
          <View style={styles.settingRow}>
            <View style={styles.settingText}>
              <Text style={styles.settingTitle}>Tu carta diaria</Text>
              <Text style={styles.settingSubtitle}>Recibe un recordatorio para abrir tu oraculo.</Text>
            </View>
            <Switch
              value={state.reminderEnabled}
              onValueChange={(value) => saveReminder(value)}
              trackColor={{ false: "#263044", true: "#9A6A35" }}
              thumbColor={state.reminderEnabled ? "#F3D39B" : "#E5E7EB"}
            />
          </View>

          <View style={styles.notificationPreview}>
            <View style={styles.previewIcon}>
              <Symbol name="EYE" color="#D7B36A" size={26} />
            </View>
            <View style={styles.previewText}>
              <Text style={styles.previewTitle}>Tarot Cotidiano</Text>
              <Text style={styles.previewBody}>Tu carta diaria te espera</Text>
            </View>
            <Text style={styles.previewTime}>ahora</Text>
          </View>

          <View style={styles.timeRow}>
            <Text style={styles.timeLabel}>Hora de notificacion</Text>
            <TextInput
              value={state.reminderTime}
              onChangeText={(value) => updateState({ reminderTime: value })}
              onBlur={() => updateState({ reminderTime: normalizeTime(state.reminderTime) })}
              keyboardType="numbers-and-punctuation"
              placeholder="08:00"
              placeholderTextColor="#7E8798"
              maxLength={5}
              style={styles.timeInput}
            />
          </View>

          <Pressable style={styles.primaryButtonFull} onPress={() => saveReminder(state.reminderEnabled, state.reminderTime)}>
            <Text style={styles.primaryButtonText}>Guardar ajustes</Text>
          </Pressable>
          <Pressable style={styles.secondaryButtonFull} onPress={sendTestNotification}>
            <Text style={styles.secondaryButtonText}>Probar notificacion</Text>
          </Pressable>
        </View>
      </ScrollView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="light" />
      <View style={styles.backgroundMoon} />
      <View style={styles.backgroundSun} />
      <View style={styles.container}>
        {activeTab === "today" && renderToday()}
        {activeTab === "categories" && renderCategories()}
        {activeTab === "saved" && renderSaved()}
        {activeTab === "settings" && renderSettings()}
      </View>
      <View style={styles.tabbar}>
        <TabButton label="Hoy" symbol="SUN" active={activeTab === "today"} onPress={() => setActiveTab("today")} />
        <TabButton label="Categorias" symbol="GRID" active={activeTab === "categories"} onPress={() => setActiveTab("categories")} />
        <TabButton label="Guardadas" symbol="BOOK" active={activeTab === "saved"} onPress={() => setActiveTab("saved")} />
        <TabButton label="Ajustes" symbol="GEAR" active={activeTab === "settings"} onPress={() => setActiveTab("settings")} />
      </View>
    </SafeAreaView>
  );
}

function TopBar({ title, subtitle, compact = false }) {
  return (
    <View style={[styles.header, compact && styles.headerCompact]}>
      <Text style={styles.appName}>Oraculo Cotidiano</Text>
      <Text style={styles.headerTitle}>{title}</Text>
      <Text style={styles.headerSubtitle}>{subtitle}</Text>
    </View>
  );
}

function TarotBack() {
  return (
    <View style={styles.tarotBack}>
      <View style={styles.cardInnerBorder}>
        <Text style={styles.cornerMark}>✦</Text>
        <View style={styles.rayCircle}>
          <View style={styles.moonShape} />
          <Text style={styles.starCenter}>✦</Text>
        </View>
        <Text style={styles.cardHint}>Toca para revelar</Text>
        <Text style={[styles.cornerMark, styles.cornerBottom]}>✦</Text>
      </View>
    </View>
  );
}

function TarotFace({ card }) {
  const category = getCategory(card.category);
  return (
    <View style={[styles.tarotFace, { backgroundColor: category.softColor, borderColor: category.color }]}>
      <Text style={[styles.faceCategory, { color: category.color }]}>{category.name}</Text>
      <View style={styles.faceSymbol}>
        <Symbol name={category.symbol} color={category.color} size={68} />
      </View>
      <Text style={styles.faceTitle}>{card.title}</Text>
      <Text style={styles.facePrompt}>{card.prompt}</Text>
    </View>
  );
}

function MiniCard({ card, saved, onSave, onShare }) {
  const category = getCategory(card.category);
  return (
    <View style={[styles.miniCard, { backgroundColor: category.softColor, borderColor: category.color }]}>
      <Symbol name={category.symbol} color={category.color} size={36} />
      <Text style={styles.miniTitle}>{card.title}</Text>
      <Text style={styles.miniMessage}>{card.message}</Text>
      <View style={styles.miniActions}>
        <Pressable style={styles.miniButton} onPress={onSave}>
          <Text style={[styles.miniButtonText, saved && { color: "#F3D39B" }]}>{saved ? "Guardada" : "Guardar"}</Text>
        </Pressable>
        <Pressable style={styles.miniButton} onPress={onShare}>
          <Text style={styles.miniButtonText}>Enviar</Text>
        </Pressable>
      </View>
    </View>
  );
}

function SavedCard({ card, onRemove, onShare }) {
  const category = getCategory(card.category);
  return (
    <View style={styles.savedCard}>
      <View style={[styles.savedSymbol, { backgroundColor: category.softColor }]}>
        <Symbol name={category.symbol} color={category.color} size={28} />
      </View>
      <View style={styles.savedContent}>
        <Text style={styles.savedTitle}>{card.title}</Text>
        <Text style={styles.savedMessage}>{card.message}</Text>
        <View style={styles.savedActions}>
          <Pressable onPress={onShare}>
            <Text style={styles.savedActionText}>Compartir</Text>
          </Pressable>
          <Pressable onPress={onRemove}>
            <Text style={styles.savedActionText}>Quitar</Text>
          </Pressable>
        </View>
      </View>
    </View>
  );
}

function TabButton({ label, symbol, active, onPress }) {
  return (
    <Pressable style={styles.tabButton} onPress={onPress}>
      <Symbol name={symbol} color={active ? "#D7B36A" : "#B8C0D0"} size={23} />
      <Text style={[styles.tabLabel, active && styles.tabLabelActive]}>{label}</Text>
    </Pressable>
  );
}

function Symbol({ name, color, size = 34 }) {
  const style = { width: size, height: size };
  if (name === "SUN") return <View style={style}><View style={[styles.sunCore, scaled(size), { borderColor: color }]} /><Text style={[styles.symbolText, { color, fontSize: size * 0.8 }]}>✶</Text></View>;
  if (name === "EYE") return <View style={style}><View style={[styles.eyeShape, { borderColor: color }]} /><View style={[styles.eyePupil, { backgroundColor: color }]} /></View>;
  if (name === "LOTUS") return <Text style={[styles.symbolText, { color, fontSize: size * 0.82 }]}>✧</Text>;
  if (name === "MOUNT") return <Text style={[styles.symbolText, { color, fontSize: size * 0.78 }]}>△</Text>;
  if (name === "HEART") return <Text style={[styles.symbolText, { color, fontSize: size * 0.72 }]}>♡</Text>;
  if (name === "HANDS") return <Text style={[styles.symbolText, { color, fontSize: size * 0.72 }]}>◇</Text>;
  if (name === "LION") return <Text style={[styles.symbolText, { color, fontSize: size * 0.72 }]}>♌</Text>;
  if (name === "PLANT") return <Text style={[styles.symbolText, { color, fontSize: size * 0.78 }]}>♧</Text>;
  if (name === "MOON") return <Text style={[styles.symbolText, { color, fontSize: size * 0.82 }]}>☾</Text>;
  if (name === "WAVES") return <Text style={[styles.symbolText, { color, fontSize: size * 0.7 }]}>≋</Text>;
  if (name === "TWO") return <Text style={[styles.symbolText, { color, fontSize: size * 0.7 }]}>☍</Text>;
  if (name === "STAR") return <Text style={[styles.symbolText, { color, fontSize: size * 0.78 }]}>✦</Text>;
  if (name === "GRID") return <Text style={[styles.symbolText, { color, fontSize: size * 0.66 }]}>▦</Text>;
  if (name === "BOOK") return <Text style={[styles.symbolText, { color, fontSize: size * 0.72 }]}>▱</Text>;
  if (name === "GEAR") return <Text style={[styles.symbolText, { color, fontSize: size * 0.7 }]}>⚙</Text>;
  return <Text style={[styles.symbolText, { color, fontSize: size * 0.75 }]}>✦</Text>;
}

function scaled(size) {
  return {
    left: size * 0.18,
    top: size * 0.18,
    width: size * 0.64,
    height: size * 0.64,
    borderRadius: size
  };
}

function getCardForToday() {
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 0);
  const day = Math.floor((now - start) / 86400000);
  return TAROT_CARDS[day % TAROT_CARDS.length];
}

function getCategory(id) {
  return CATEGORIES.find((category) => category.id === id) || CATEGORIES[0];
}

function formatToday() {
  return new Intl.DateTimeFormat("es", {
    weekday: "long",
    day: "numeric",
    month: "long"
  }).format(new Date());
}

function normalizeTime(value) {
  const match = /^(\d{1,2}):?(\d{2})$/.exec(value.trim());
  if (!match) return "08:00";
  const hours = Math.min(23, Math.max(0, Number(match[1])));
  const minutes = Math.min(59, Math.max(0, Number(match[2])));
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}

async function scheduleDailyReminder(time) {
  await cancelDailyReminder();
  const [hour, minute] = time.split(":").map(Number);
  const card = getCardForToday();
  const id = await Notifications.scheduleNotificationAsync({
    content: {
      title: "Tu carta diaria te espera",
      body: card.title
    },
    trigger: {
      type: Notifications.SchedulableTriggerInputTypes.DAILY,
      hour,
      minute
    }
  });
  await AsyncStorage.setItem(DAILY_NOTIFICATION_ID_KEY, id);
}

async function cancelDailyReminder() {
  const id = await AsyncStorage.getItem(DAILY_NOTIFICATION_ID_KEY);
  if (id) {
    await Notifications.cancelScheduledNotificationAsync(id);
    await AsyncStorage.removeItem(DAILY_NOTIFICATION_ID_KEY);
  }
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: "#070B18"
  },
  backgroundMoon: {
    position: "absolute",
    top: -90,
    left: -90,
    width: 240,
    height: 240,
    borderRadius: 240,
    backgroundColor: "rgba(55, 76, 122, 0.28)"
  },
  backgroundSun: {
    position: "absolute",
    top: 120,
    right: -120,
    width: 250,
    height: 250,
    borderRadius: 250,
    backgroundColor: "rgba(186, 94, 54, 0.22)"
  },
  container: {
    flex: 1,
    paddingHorizontal: 18
  },
  screen: {
    flex: 1,
    paddingTop: 16,
    paddingBottom: 108
  },
  scrollContent: {
    paddingTop: 16,
    paddingBottom: 116
  },
  header: {
    alignItems: "center",
    marginBottom: 22
  },
  headerCompact: {
    marginBottom: 12
  },
  appName: {
    overflow: "hidden",
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.55)",
    borderRadius: 999,
    paddingHorizontal: 18,
    paddingVertical: 5,
    color: "#D7B36A",
    fontSize: 12,
    fontWeight: "800",
    letterSpacing: 2,
    textTransform: "uppercase"
  },
  headerTitle: {
    marginTop: 10,
    color: "#F4D7A1",
    fontSize: 34,
    fontWeight: "700",
    letterSpacing: 0,
    textAlign: "center"
  },
  headerSubtitle: {
    marginTop: 5,
    color: "#D6D9E3",
    fontSize: 15,
    lineHeight: 21,
    textAlign: "center"
  },
  dailyIntro: {
    alignItems: "center",
    marginBottom: 16
  },
  kicker: {
    color: "#F1C47D",
    fontSize: 15,
    fontWeight: "700"
  },
  dailyTitle: {
    marginTop: 8,
    color: "#FFF4DF",
    fontSize: 28,
    fontWeight: "700",
    textAlign: "center"
  },
  dailySubtitle: {
    marginTop: 7,
    maxWidth: 300,
    color: "#C8CEDC",
    fontSize: 15,
    lineHeight: 21,
    textAlign: "center"
  },
  deckStage: {
    alignSelf: "center",
    width: 228,
    height: 338,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderRadius: 34,
    backgroundColor: "rgba(10, 17, 36, 0.7)"
  },
  aura: {
    position: "absolute",
    width: 260,
    height: 260,
    borderRadius: 260,
    opacity: 0.16
  },
  tarotBack: {
    width: 194,
    height: 294,
    borderWidth: 2,
    borderColor: "#D7A75F",
    borderRadius: 24,
    padding: 11,
    backgroundColor: "#091126"
  },
  cardInnerBorder: {
    flex: 1,
    alignItems: "center",
    justifyContent: "space-between",
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.66)",
    borderRadius: 17,
    paddingVertical: 14
  },
  cornerMark: {
    color: "#D7B36A",
    fontSize: 22
  },
  cornerBottom: {
    transform: [{ rotate: "180deg" }]
  },
  rayCircle: {
    width: 132,
    height: 132,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.56)",
    borderRadius: 132
  },
  moonShape: {
    position: "absolute",
    width: 62,
    height: 62,
    borderRadius: 62,
    borderWidth: 8,
    borderColor: "#D7A75F"
  },
  starCenter: {
    marginLeft: 46,
    marginTop: -10,
    color: "#F3D39B",
    fontSize: 19
  },
  cardHint: {
    color: "#F3D39B",
    fontSize: 13,
    fontWeight: "700"
  },
  tarotFace: {
    width: 194,
    height: 294,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 2,
    borderRadius: 24,
    padding: 18
  },
  faceCategory: {
    position: "absolute",
    top: 18,
    fontSize: 12,
    fontWeight: "900",
    letterSpacing: 1.2,
    textTransform: "uppercase"
  },
  faceSymbol: {
    marginBottom: 18
  },
  faceTitle: {
    color: "#FFF4DF",
    fontSize: 24,
    fontWeight: "800",
    textAlign: "center"
  },
  facePrompt: {
    marginTop: 13,
    color: "#DFE3ED",
    fontSize: 13,
    lineHeight: 18,
    textAlign: "center"
  },
  messagePanel: {
    marginTop: 20,
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.22)",
    borderRadius: 24,
    padding: 20,
    backgroundColor: "rgba(13, 22, 44, 0.88)"
  },
  messageCategory: {
    fontSize: 12,
    fontWeight: "900",
    letterSpacing: 1.2,
    textTransform: "uppercase"
  },
  messageText: {
    marginTop: 10,
    color: "#F3F0EA",
    fontSize: 20,
    lineHeight: 29,
    fontWeight: "600"
  },
  actionRow: {
    flexDirection: "row",
    marginTop: 18
  },
  primaryButton: {
    minHeight: 48,
    justifyContent: "center",
    borderRadius: 999,
    paddingHorizontal: 24,
    backgroundColor: "#B97B3B"
  },
  primaryButtonText: {
    color: "#FFF6E7",
    fontSize: 15,
    fontWeight: "900"
  },
  secondaryButton: {
    minHeight: 48,
    justifyContent: "center",
    marginLeft: 10,
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.38)",
    borderRadius: 999,
    paddingHorizontal: 18,
    backgroundColor: "rgba(255, 255, 255, 0.05)"
  },
  secondaryButtonText: {
    color: "#F4D7A1",
    fontSize: 15,
    fontWeight: "800"
  },
  categoryGrid: {
    paddingTop: 8,
    paddingBottom: 14
  },
  categoryRow: {
    justifyContent: "space-between",
    marginBottom: 10
  },
  categoryCard: {
    width: "31.4%",
    aspectRatio: 0.72,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderRadius: 13,
    padding: 8
  },
  categoryName: {
    marginTop: 13,
    color: "#FFF4DF",
    fontSize: 12,
    fontWeight: "800",
    textAlign: "center"
  },
  sectionTitle: {
    marginTop: 6,
    marginBottom: 10,
    color: "#F4D7A1",
    fontSize: 20,
    fontWeight: "800"
  },
  horizontalCards: {
    paddingBottom: 18
  },
  miniCard: {
    width: 236,
    minHeight: 318,
    borderWidth: 1,
    borderRadius: 20,
    padding: 18,
    marginRight: 13
  },
  miniTitle: {
    marginTop: 14,
    color: "#FFF4DF",
    fontSize: 21,
    fontWeight: "800"
  },
  miniMessage: {
    marginTop: 10,
    color: "#E7EAF2",
    fontSize: 15,
    lineHeight: 22
  },
  miniActions: {
    flexDirection: "row",
    marginTop: "auto",
    paddingTop: 16
  },
  miniButton: {
    minHeight: 38,
    justifyContent: "center",
    borderRadius: 999,
    paddingHorizontal: 13,
    marginRight: 8,
    backgroundColor: "rgba(255, 255, 255, 0.08)"
  },
  miniButtonText: {
    color: "#D7B36A",
    fontSize: 13,
    fontWeight: "800"
  },
  savedCard: {
    flexDirection: "row",
    marginBottom: 13,
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.2)",
    borderRadius: 20,
    padding: 15,
    backgroundColor: "rgba(13, 22, 44, 0.82)"
  },
  savedSymbol: {
    width: 54,
    height: 74,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 14
  },
  savedContent: {
    flex: 1,
    marginLeft: 14
  },
  savedTitle: {
    color: "#FFF4DF",
    fontSize: 18,
    fontWeight: "800"
  },
  savedMessage: {
    marginTop: 6,
    color: "#D9DEE9",
    fontSize: 14,
    lineHeight: 20
  },
  savedActions: {
    flexDirection: "row",
    marginTop: 11
  },
  savedActionText: {
    marginRight: 16,
    color: "#D7B36A",
    fontSize: 13,
    fontWeight: "800"
  },
  emptyState: {
    minHeight: 330,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.2)",
    borderRadius: 24,
    padding: 24,
    backgroundColor: "rgba(13, 22, 44, 0.8)"
  },
  emptyTitle: {
    marginTop: 18,
    color: "#FFF4DF",
    fontSize: 22,
    fontWeight: "800",
    textAlign: "center"
  },
  emptyText: {
    marginTop: 9,
    color: "#D9DEE9",
    fontSize: 15,
    lineHeight: 22,
    textAlign: "center"
  },
  settingsPanel: {
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.2)",
    borderRadius: 24,
    padding: 16,
    backgroundColor: "rgba(13, 22, 44, 0.86)"
  },
  settingRow: {
    flexDirection: "row",
    alignItems: "center"
  },
  settingText: {
    flex: 1,
    paddingRight: 12
  },
  settingTitle: {
    color: "#FFF4DF",
    fontSize: 20,
    fontWeight: "800"
  },
  settingSubtitle: {
    marginTop: 5,
    color: "#D9DEE9",
    fontSize: 14,
    lineHeight: 20
  },
  notificationPreview: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 18,
    borderRadius: 16,
    padding: 12,
    backgroundColor: "rgba(244, 247, 255, 0.88)"
  },
  previewIcon: {
    width: 46,
    height: 46,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 11,
    backgroundColor: "#081126"
  },
  previewText: {
    flex: 1,
    marginLeft: 12
  },
  previewTitle: {
    color: "#111827",
    fontSize: 14,
    fontWeight: "800"
  },
  previewBody: {
    marginTop: 3,
    color: "#1F2937",
    fontSize: 14
  },
  previewTime: {
    color: "#4B5563",
    fontSize: 12
  },
  timeRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginTop: 18,
    borderTopWidth: 1,
    borderTopColor: "rgba(215, 179, 106, 0.16)",
    paddingTop: 16
  },
  timeLabel: {
    color: "#FFF4DF",
    fontSize: 16,
    fontWeight: "700"
  },
  timeInput: {
    width: 90,
    minHeight: 44,
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.25)",
    borderRadius: 13,
    paddingHorizontal: 10,
    color: "#FFF4DF",
    backgroundColor: "rgba(255, 255, 255, 0.06)",
    fontSize: 17,
    fontWeight: "800",
    textAlign: "center"
  },
  primaryButtonFull: {
    minHeight: 50,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 20,
    borderRadius: 999,
    backgroundColor: "#B97B3B"
  },
  secondaryButtonFull: {
    minHeight: 50,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 10,
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.28)",
    borderRadius: 999,
    backgroundColor: "rgba(255, 255, 255, 0.04)"
  },
  tabbar: {
    position: "absolute",
    left: 16,
    right: 16,
    bottom: 16,
    flexDirection: "row",
    minHeight: 74,
    borderWidth: 1,
    borderColor: "rgba(215, 179, 106, 0.22)",
    borderRadius: 26,
    backgroundColor: "rgba(7, 12, 28, 0.96)"
  },
  tabButton: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center"
  },
  tabLabel: {
    marginTop: 5,
    color: "#B8C0D0",
    fontSize: 11,
    fontWeight: "700"
  },
  tabLabelActive: {
    color: "#D7B36A"
  },
  symbolText: {
    width: "100%",
    height: "100%",
    textAlign: "center",
    textAlignVertical: "center",
    fontWeight: "700"
  },
  sunCore: {
    position: "absolute",
    borderWidth: 2
  },
  eyeShape: {
    position: "absolute",
    left: 3,
    right: 3,
    top: "28%",
    height: "44%",
    borderWidth: 2,
    borderRadius: 999,
    transform: [{ rotate: "-12deg" }]
  },
  eyePupil: {
    position: "absolute",
    left: "42%",
    top: "42%",
    width: "16%",
    height: "16%",
    borderRadius: 99
  }
});
