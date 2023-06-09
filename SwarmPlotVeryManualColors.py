import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


clipboardData = pd.read_clipboard(header=0)
# Read data from clipboard. Each sample is in a column. The first row of each column is the sample name.


custom_palette = {"A": sns.light_palette((0, 0.7, 0), n_colors=10)[9],
                  "B": sns.light_palette((0, 0.45, 0), n_colors=10)[9],
                  "C": sns.light_palette((0.95, 0.4, 0.4), n_colors=10)[9],
                  "D": sns.light_palette((1, 0, 0), n_colors=10)[9],
                  "E": sns.light_palette((0.1, 0.6, 1), n_colors=10)[9],
                  "F": sns.light_palette((0, 0.2, 0.8), n_colors=10)[9]}

plt.rcParams['axes.linewidth'] = 1
plt.rcParams['xtick.major.size'] = 4
plt.rcParams['xtick.major.width'] = 1
plt.rcParams['ytick.major.size'] = 4
plt.rcParams['ytick.major.width'] = 1
plt.rcParams['xtick.labelsize'] = 5
plt.rcParams['ytick.labelsize'] = 13
plt.rcParams['font.family'] = 'arial'
plt.rcParams['xtick.major.pad'] = 15

ax = sns.swarmplot(data=clipboardData, size=6, zorder=0, palette=custom_palette)
# The size parameter above controls the size of the dots. Default is 5.
sns.boxplot(data=clipboardData, fliersize=0, showbox=0, showcaps=1, whis=0, color='0', width=0.5, linewidth=2)
sns.boxplot(data=clipboardData, fliersize=0, showbox=1, showcaps=0, whis=0, color='0', width=0.001, linewidth=2)

plt.ylabel('Replication time (min)', fontsize=18)
# Set the label for the Y axis and the size of the font.
plt.ylim([0, 50])
# Set the lower and upper limits of the Y axis.
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)

plt.show()
