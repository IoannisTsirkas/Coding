import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


clipboardData = pd.read_clipboard(header=0)
# Read data from clipboard. Each sample is in a column. The first row of each column is the sample name.

ax = sns.violinplot(data=clipboardData, zorder=0)

plt.ylabel('Number of RNAs at the transcription site', fontsize='x-large')
# Set the label for the Y axis and the size of the font.
plt.ylim([0, 30])
# Set the lower and upper limits of the Y axis.
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
plt.show()