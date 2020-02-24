import pandas as pd


class BaseballData:
    def __init__(self, player_data_csv='data/People.csv',
                 appearance_data_csv='data/Appearances.csv',
                 pitching_data_csv='data/Pitching.csv',
                 batting_data_csv='data/Batting.csv',
                 salary_data_csv='data/Salaries.csv'):
        self.player_data = pd.read_csv(player_data_csv)
        self.appearance_data = pd.read_csv(appearance_data_csv)
        self.pitching_data = pd.read_csv(pitching_data_csv)
        self.batting_data = pd.read_csv(batting_data_csv)
        self.salary_data = pd.read_csv(salary_data_csv)

    def get_playerid(last_name, first_name=None):
        if first_name:
            playerid = player_data.loc[(player_data['nameLast'] == last_name) &
                                       (player_data['nameFirst'] == first_name)]['playerID']
        else:
            playerid = player_data.loc[(player_data['nameLast'] == last_name)]['playerID']
        return playerid

    def is_pitcher(playerid):
        pass

    def get_player_pitching(playerid):
        pass

    def get_player_batting(playerid):
        pass

    def get_player_fielding(playerid):
        pass

