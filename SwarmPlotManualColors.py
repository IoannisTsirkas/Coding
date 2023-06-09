
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


clipboardData = pd.read_clipboard(header=0)
# Read data from clipboard. Each sample is in a column. The first row of each column is the sample name.

custom_palette = {"A": sns.color_palette()[0],
                  "B": sns.color_palette()[1]}
# Select color from 0-9 for each data label.

ax = sns.swarmplot(data=clipboardData, size=5, zorder=0, palette=custom_palette)
# The size parameter above controls the size of the dots. Default is 5.
sns.boxplot(data=clipboardData, fliersize=0, showbox=0, showcaps=1, whis=0, color='0', width=0.5)
sns.boxplot(data=clipboardData, fliersize=0, showbox=1, showcaps=0, whis=0, color='0', width=0.001)

plt.ylabel('Replication time (min)', fontsize='x-large')
# Set the label for the Y axis and the size of the font.
plt.ylim([0, 10])
# Set the lower and upper limits of the Y axis.
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
plt.show()
