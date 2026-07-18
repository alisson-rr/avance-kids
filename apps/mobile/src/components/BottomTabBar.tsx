import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import Svg, { Path } from 'react-native-svg';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useNavigation } from '@react-navigation/native';
import { theme } from '../theme';

const ProfileIcon = ({ color }: { color: string }) => (
  <Svg width="28" height="28" viewBox="269 26 30 30" fill="none">
    <Path fillRule="evenodd" clipRule="evenodd" d="M298.166 41C298.166 48.824 291.824 55.1666 284 55.1666C276.176 55.1666 269.833 48.824 269.833 41C269.833 33.1759 276.176 26.8333 284 26.8333C291.824 26.8333 298.166 33.1759 298.166 41ZM288.25 36.75C288.25 39.0972 286.347 41 284 41C281.652 41 279.75 39.0972 279.75 36.75C279.75 34.4028 281.652 32.5 284 32.5C286.347 32.5 288.25 34.4028 288.25 36.75ZM284 53.0416C286.527 53.0416 288.873 52.263 290.809 50.9325C291.665 50.3449 292.031 49.2255 291.533 48.3146C290.502 46.4262 288.378 45.25 284 45.25C279.622 45.25 277.497 46.4261 276.466 48.3145C275.969 49.2254 276.334 50.3448 277.19 50.9324C279.127 52.263 281.472 53.0416 284 53.0416Z" fill={color}/>
  </Svg>
);

const PlanIcon = ({ color }: { color: string }) => (
  <Svg width="28" height="28" viewBox="174 20 30 30" fill="none">
    <Path fillRule="evenodd" clipRule="evenodd" d="M176.908 22.908C174.833 24.9826 174.833 28.3217 174.833 35C174.833 41.6782 174.833 45.0173 176.908 47.092C178.982 49.1666 182.321 49.1666 189 49.1666C195.678 49.1666 199.017 49.1666 201.092 47.092C203.166 45.0173 203.166 41.6782 203.166 35C203.166 28.3217 203.166 24.9826 201.092 22.908C199.017 20.8333 195.678 20.8333 189 20.8333C182.321 20.8333 178.982 20.8333 176.908 22.908ZM186.936 28.6494C187.34 28.2245 187.324 27.5519 186.899 27.1473C186.474 26.7426 185.802 26.759 185.397 27.1839L182.119 30.626L181.269 29.7339C180.864 29.309 180.192 29.2926 179.767 29.6973C179.342 30.1019 179.326 30.7745 179.73 31.1994L181.349 32.8994C181.55 33.11 181.828 33.2291 182.119 33.2291C182.41 33.2291 182.688 33.11 182.888 32.8994L186.936 28.6494ZM190.416 29.6875C189.83 29.6875 189.354 30.1632 189.354 30.75C189.354 31.3368 189.83 31.8125 190.416 31.8125H197.5C198.086 31.8125 198.562 31.3368 198.562 30.75C198.562 30.1632 198.086 29.6875 197.5 29.6875H190.416ZM186.936 38.5661C187.34 38.1411 187.324 37.4686 186.899 37.0639C186.474 36.6592 185.802 36.6756 185.397 37.1006L182.119 40.5427L181.269 39.6506C180.864 39.2256 180.192 39.2092 179.767 39.6139C179.342 40.0186 179.326 40.6911 179.73 41.1161L181.349 42.8161C181.55 43.0266 181.828 43.1458 182.119 43.1458C182.41 43.1458 182.688 43.0266 182.888 42.8161L186.936 38.5661ZM190.416 39.6041C189.83 39.6041 189.354 40.0798 189.354 40.6666C189.354 41.2534 189.83 41.7291 190.416 41.7291H197.5C198.086 41.7291 198.562 41.2534 198.562 40.6666C198.562 40.0798 198.086 39.6041 197.5 39.6041H190.416Z" fill={color}/>
  </Svg>
);

const HomeIcon = ({ color }: { color: string }) => (
  <Svg width="28" height="28" viewBox="87 26 29 29" fill="none">
    <Path fillRule="evenodd" clipRule="evenodd" d="M88.0685 34.6875C87.333 36.0313 87.333 37.6523 87.333 40.8942V43.049C87.333 48.5753 87.333 51.3384 88.9927 53.0552C90.6525 54.772 93.3238 54.772 98.6663 54.772H104.333C109.676 54.772 112.347 54.772 114.007 53.0552C115.666 51.3384 115.666 48.5753 115.666 43.049V40.8942C115.666 37.6523 115.666 36.0313 114.931 34.6875C114.195 33.3438 112.852 32.5098 110.164 30.8418L107.331 29.0834C104.49 27.3202 103.069 26.4387 101.5 26.4387C99.9301 26.4387 98.5096 27.3202 95.6687 29.0834L92.8354 30.8418C90.1478 32.5098 88.8041 33.3438 88.0685 34.6875ZM97.2497 48.0428C96.6629 48.0428 96.1872 48.5185 96.1872 49.1053C96.1872 49.6921 96.6629 50.1678 97.2497 50.1678H105.75C106.336 50.1678 106.812 49.6921 106.812 49.1053C106.812 48.5185 106.336 48.0428 105.75 48.0428H97.2497Z" fill={color}/>
  </Svg>
);

type BottomTabBarProps = {
  activeScreen: 'Home' | 'ActivityPlan' | 'Settings';
};

export const BottomTabBar = ({ activeScreen }: BottomTabBarProps) => {
  const insets = useSafeAreaInsets();
  const navigation = useNavigation<any>();

  return (
    <View style={[styles.bottomTabBar, { paddingBottom: Math.max(insets.bottom, 16) }]}>
      <TouchableOpacity style={styles.tabItem} onPress={() => navigation.navigate('Home')}>
        <HomeIcon color={activeScreen === 'Home' ? theme.colors.primary : '#C9C9C9'} />
        <Text style={[styles.tabLabel, activeScreen === 'Home' && { color: theme.colors.primary }]}>Início</Text>
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.tabItem} onPress={() => navigation.navigate('ActivityPlan')}>
        <PlanIcon color={activeScreen === 'ActivityPlan' ? theme.colors.primary : '#C9C9C9'} />
        <Text style={[styles.tabLabel, activeScreen === 'ActivityPlan' && { color: theme.colors.primary }]}>{'Plano de\nAtividades'}</Text>
      </TouchableOpacity>
      
      <TouchableOpacity style={styles.tabItem} onPress={() => navigation.navigate('Settings')}>
        <ProfileIcon color={activeScreen === 'Settings' ? theme.colors.primary : '#C9C9C9'} />
        <Text style={[styles.tabLabel, activeScreen === 'Settings' && { color: theme.colors.primary }]}>Meu perfil</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  bottomTabBar: {
    width: '100%',
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderTopColor: '#EBEBEB',
    paddingTop: 12,
  },
  tabItem: {
    alignItems: 'center',
    flex: 1,
  },
  tabLabel: {
    fontFamily: theme.fonts.semiBold,
    fontSize: 10,
    color: '#727272',
    marginTop: 7,
    textAlign: 'center',
  },
});
