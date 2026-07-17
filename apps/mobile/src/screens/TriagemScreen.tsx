import React from 'react';
import {
  StyleSheet,
  View,
  Text,
  SafeAreaView,
  TouchableOpacity,
  ScrollView,
  StatusBar,
  Platform,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { theme } from '../theme';
import { Button } from '../components/Button';

// ─── DATA ─────────────────────────────────────────────────────────────
const HABILIDADES = [
  {
    id: 1,
    nome: 'Comunicação',
    total: 5,
    respondidas: 0,
    circleColor: '#FFCF4D',
  },
  {
    id: 2,
    nome: 'Social',
    total: 4,
    respondidas: 0,
    circleColor: '#82C302',
  },
  {
    id: 3,
    nome: 'Cognitiva',
    total: 4,
    respondidas: 0,
    circleColor: '#9F67FF',
  },
  {
    id: 4,
    nome: 'Coordenação motora',
    total: 4,
    respondidas: 0,
    circleColor: '#FF8E25',
  },
  {
    id: 5,
    nome: 'Funcional',
    total: 4,
    respondidas: 0,
    circleColor: '#FE6D94',
  },
];

// ─── COMPONENT ────────────────────────────────────────────────────────
export function TriagemScreen({ navigation }: any) {
  const insets = useSafeAreaInsets();
  const safeTop = Math.max(insets.top, 50);

  return (
    <View style={[styles.safeArea, { paddingTop: safeTop, paddingBottom: insets.bottom }]}>
      <StatusBar barStyle="dark-content" backgroundColor="#FAFAFA" />

      {/* ── HEADER SECTION (193px tall in Figma) ── */}
      <View style={styles.headerSection}>
        {/* Title row: só ‹ agora (ⓘ removido) */}
        <View style={styles.titleRow}>
          <TouchableOpacity
            onPress={() => navigation.goBack()}
            style={styles.iconBtn}
            hitSlop={{ top: 12, bottom: 12, left: 12, right: 12 }}
          >
            <Text style={styles.chevron}>‹</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.titleBlock}>
          <Text style={styles.pageTitle}>Habilidades</Text>
          <Text style={styles.pageDescription}>
            Responda para receber o plano personalizado para o desenvolvimento de [nome da criança].
          </Text>
        </View>
      </View>

      {/* ── CARDS + BUTTON ── */}
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        bounces={false}
      >
        {/* Skills cards */}
        <View style={styles.cardsList}>
          {HABILIDADES.map((hab) => (
            <TouchableOpacity
              key={hab.id}
              style={styles.card}
              activeOpacity={0.7}
              onPress={() => navigation.navigate('Habilidade', { habilidadeId: hab.id })}
            >
              {/* Colored circle */}
              <View style={[styles.circle, { backgroundColor: hab.circleColor }]} />

              {/* Right content */}
              <View style={styles.cardRight}>
                {/* Title + count */}
                <View style={styles.cardMeta}>
                  <View style={styles.cardTitleGroup}>
                    <Text style={styles.cardTitle}>{hab.nome}</Text>
                  </View>
                  <View style={styles.cardCountGroup}>
                    <Text style={styles.cardCount}>
                      {hab.respondidas}/{hab.total}
                    </Text>
                  </View>
                </View>

                {/* Responder link */}
                <View style={styles.responderRow}>
                  <Text style={styles.responderText}>Responder</Text>
                  <Text style={styles.responderArrow}>›</Text>
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </View>

        <View style={styles.bottomActions}>
          <Button title="Concluir" onPress={() => navigation.navigate('Onboarding3')} />
          <TouchableOpacity style={styles.ghostBtn} onPress={() => navigation.navigate('Onboarding3')}>
            <Text style={styles.ghostBtnText}>Responder depois</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </View>
  );
}

// ─── STYLES ───────────────────────────────────────────────────────────
const styles = StyleSheet.create({
  // ── Screen ──────────────────────────────────────────────────────────
  safeArea: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },

  // ── Header section ──────────────────────────────────────────────
  // Figma: Frame 427319673, 393×193px
  headerSection: {
    paddingHorizontal: 24,
    gap: 24,
  },
  titleRow: {
    // Figma: row, space-between, gap 279px, height 24px
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 24,
  },
  iconBtn: {
    width: 24,
    height: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  chevron: {
    // Figma: border 1.5px solid #000000
    fontSize: 28,
    color: '#000000',
    lineHeight: 30,
    marginTop: -2,
  },
  infoIcon: {
    // Figma: border 1.5px solid #000000
    fontSize: 20,
    color: '#000000',
  },
  titleBlock: {
    // Figma: Frame 427319674, gap 8px, 345×71px
    gap: 8,
  },
  pageTitle: {
    // Figma: Inter 700, 24px, line-height 29px, #000000
    fontFamily: theme.fonts.semiBold,
    fontSize: 24,
    lineHeight: 29,
    color: '#000000',
    fontWeight: '700',
  },
  pageDescription: {
    // Figma: Inter 400, 14px, line-height 17px, #000000
    fontFamily: theme.fonts.regular,
    fontSize: 14,
    lineHeight: 17,
    color: '#000000',
  },

  // ── ScrollView ──────────────────────────────────────────────────
  scrollContent: {
    paddingBottom: 40,
  },

  // ── Cards list ──────────────────────────────────────────────────
  // Figma: Frame 427319657, padding 0 24px, gap 16px
  cardsList: {
    paddingHorizontal: 24,
    paddingTop: 24,
    gap: 16,
  },

  // ── Card ────────────────────────────────────────────────────────
  // Figma: row, padding 24px, gap 16px, 345×124px, bg #FFF, shadow, radius 12
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 24,
    gap: 16,
    height: 124,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    // Figma: box-shadow 0px 2px 12px rgba(170,170,170,0.25)
    shadowColor: '#AAAAAA',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 4,
  },

  // ── Circle ──────────────────────────────────────────────────────
  // Figma: 76×76px, border-radius 100px
  circle: {
    width: 76,
    height: 76,
    borderRadius: 100,
  },

  // ── Card right content ──────────────────────────────────────────
  // Figma: Frame 427319642, column, gap 12px, 205×~75px, flex-grow 1
  cardRight: {
    flex: 1,
    justifyContent: 'center',
    gap: 12,
  },

  // ── Card meta (title + count) ───────────────────────────────────
  // Figma: Frame 427319640, gap 8px
  cardMeta: {
    gap: 8,
  },
  cardTitleGroup: {
    gap: 12,
  },
  cardTitle: {
    // Figma: Inter 700, 16px, line-height 19px, #424242
    fontFamily: theme.fonts.semiBold,
    fontSize: 16,
    lineHeight: 19,
    color: '#424242',
    fontWeight: '700',
  },
  cardCountGroup: {
    gap: 12,
  },
  cardCount: {
    // Figma: Inter 400, 12px, line-height 15px, #424242
    fontFamily: theme.fonts.regular,
    fontSize: 12,
    lineHeight: 15,
    color: '#424242',
  },

  // ── Responder link ──────────────────────────────────────────────
  // Figma: Frame 427319614, row, gap 10px, 205×~25px
  responderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  responderText: {
    // Figma: Inter 600, 14px, line-height 17px, #3678FD, flex-grow 1
    fontFamily: theme.fonts.semiBold,
    fontSize: 14,
    lineHeight: 17,
    color: '#3678FD',
    flex: 1,
  },
  responderArrow: {
    // Figma: arrow icon, #3678FD
    fontSize: 18,
    color: '#3678FD',
    lineHeight: 20,
  },

  // ── Bottom actions ──────────────────────────────────────────────
  bottomActions: {
    paddingHorizontal: 24,
    paddingTop: 24,
    alignItems: 'center',
    gap: 16,
  },
  ghostBtn: {
    alignItems: 'center',
    paddingVertical: 4,
  },
  ghostBtnText: {
    // Figma: Inter 500, 16px, line-height 19px, #727272
    fontFamily: theme.fonts.medium,
    fontSize: 16,
    lineHeight: 19,
    color: '#727272',
    textAlign: 'center',
  },
});
