import pandas as pd
import numpy as np


class BaseballData:
    def __init__(self, player_data_csv='data/People.csv',
                 appearance_data_csv='data/Appearances.csv',
                 pitching_data_csv='data/Pitching.csv',
                 batting_data_csv='data/Batting.csv',
                 fielding_data_csv='data/Fielding.csv',
                 salary_data_csv='data/Salaries.csv',
                 startyear=2018, endyear=2019):
        self.startyear = startyear
        self.endyear = endyear

        player_data_raw = pd.read_csv(player_data_csv)
        appearance_data_raw = pd.read_csv(appearance_data_csv)
        pitching_data_raw = pd.read_csv(pitching_data_csv)
        batting_data_raw = pd.read_csv(batting_data_csv)
        fielding_data_raw = pd.read_csv(fielding_data_csv)
        salary_data_raw = pd.read_csv(salary_data_csv)

        self.player_data = self._limit_years(player_data_raw, startyear, endyear)
        self.appearance_data = self._limit_years(appearance_data_raw, player_data_raw, startyear, endyear)
        self.pitching_data = self._limit_years(pitching_data_raw, startyear, endyear)
        self.batting_data = self._limit_years(batting_data_raw, startyear, endyear)
        self.fielding_data = self._limit_years(fielding_data_raw, startyear, endyear)
        self.salary_data = self._limit_years(salary_data_raw, startyear, endyear)

    def _limit_years(self, df, startyear, endyear, index='yearID'):
        return df.loc[(df[index] >= startyear) & (df[index] <= endyear)]

    def _get_data(self, df, index, value):
        try:
            return df.loc[df[index].isin(value)]
        except TypeError:
            return df.loc[df[index] == value]

    def players(self, startyear=self.startyear, endyear=self.endyear, min_games=10):
        return self.appearance_data.loc[(self.appearance_data['yearID'] >= startyear) & (self.appearance_data['yearID'] <= 2019) & (self.appearance_data['G_all'] > min_games)]['playerID']

    def get_playerid(self, last_name, first_name=None):
        if first_name:
            playerid = self.player_data.loc[(self.player_data['nameLast'] == last_name) & (self.player_data['nameFirst'] == first_name)]['playerID']
        else:
            playerid = self.player_data.loc[(self.player_data['nameLast'] == last_name)]['playerID']
        return playerid

    def get_player_name(self, playerid):
        data = self._get_data(self.player_data, 'playerID', playerid)
        return f"{data['nameFirst'].values[0]} {data['nameLast'].values[0]}"

    def is_pitcher(self, playerid):
        player_fielding_data = self._get_data(self.fielding_data, 'playerID', playerid)
        return (player_fielding_data['POS'] == 'P').values[0]

    def get_player_pitching(self, playerid):
        if not self.is_pitcher(playerid):
            return None
        return self._get_data(self.pitching_data, 'playerID', playerid)

    def get_player_batting(self, playerid):
        return self._get_data(self.batting_data, 'playerID', playerid)

    def get_player_fielding(self, playerid):
        return self._get_data(self.fielding_data, 'playerID', playerid)

    def get_salaries(self, playerid):
        return self._get_data(self.salary_data, 'playerID', playerid)

