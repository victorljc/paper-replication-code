import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor, ExtraTreesRegressor, HistGradientBoostingRegressor, VotingRegressor
from sklearn.model_selection import cross_val_score, KFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer



print(f"正在读取数据: {file_path} ...")
try:
    df = pd.read_excel(file_path, engine='openpyxl')
except ImportError:
    print("错误: 请安装 openpyxl 库 (pip install openpyxl)")
    raise

df.columns = df.columns.str.strip()



features = [
    'x1装机容量', 'x2就业人数', 'x3能源消耗', 'x4发电量', 'x5直接排放',
    'x6新增火电装机', 'x7新增水电装机', 'x8新增风电装机', 'x9新增光伏装机',
    'x11新增核电装机', 'x12新增其他装机',
    'x13火力发电量', 'x13核能发电量',
    'x14火电投资', 'x15水电投资', 'x16风电投资', 'x17光伏投资', 'x18核电投资', 'x19其他投资',
    'x20施工规模', 'x21新开工规模',
    '年份', 
    '输入电力', '输出电力'
]
df[features] = df[features].fillna(0)

epsilon = 1e-6 # 防止除以0

df['intensity_emission_energy'] = df['x5直接排放'] / (df['x3能源消耗'] + epsilon)



df['intensity_emission_power'] = df['x5直接排放'] / (df['x4发电量'] + epsilon)



df['share_thermal_power'] = df['x13火力发电量'] / (df['x4发电量'] + epsilon)



df['net_power_import'] = df['输入电力'] - df['输出电力']



df['import_ratio'] = df['输入电力'] / (df['x4发电量'] + df['输入电力'] + epsilon)

df = df.sort_values(by=['id', '年份'])
lag_cols = ['x4发电量', 'x13火力发电量', 'x3能源消耗', 'x5直接排放', '输入电力', '输出电力', 'net_power_import']
for col in lag_cols:
    df[f'lag_{col}'] = df.groupby('id')[col].shift(1).fillna(0)

new_derived_features = ['intensity_emission_energy', 'intensity_emission_power', 'share_thermal_power', 'import_ratio']
final_features = features + ['net_power_import'] + [f'lag_{c}' for c in lag_cols] + new_derived_features

train_mask = df['间接排放'].notna()
predict_mask = df['间接排放'].isna()

X_train = df.loc[train_mask, final_features + ['id']]
y_train = df.loc[train_mask, '间接排放']
X_predict = df.loc[predict_mask, final_features + ['id']]

y_train_log = np.log1p(y_train)

preprocessor = ColumnTransformer(
    transformers=[
        ('cat', OneHotEncoder(handle_unknown='ignore', sparse_output=False), ['id']),
        ('num', StandardScaler(), final_features)
    ]
)

rf = RandomForestRegressor(n_estimators=500, random_state=42, n_jobs=-1)
et = ExtraTreesRegressor(n_estimators=500, random_state=42, n_jobs=-1)
hgb = HistGradientBoostingRegressor(max_iter=500, random_state=42, l2_regularization=0.1)



ensemble = VotingRegressor(
    estimators=[('rf', rf), ('et', et), ('hgb', hgb)],
    weights=[1, 1, 2] 
)

model_pipeline = Pipeline(steps=[
    ('preprocessor', preprocessor),
    ('regressor', ensemble)
])

print("\n------ 模型验证结果 ------")
kf = KFold(n_splits=5, shuffle=True, random_state=42)
scores = cross_val_score(model_pipeline, X_train, y_train_log, cv=kf, scoring='r2')

print(f"各折 R² 分数: {scores}")
print(f"平均 R² 分数: {scores.mean():.4f}")
print(f"最高单折精度: {scores.max():.4f}")
print("------------------------\n")

print("正在使用所有数据进行最终训练...")
model_pipeline.fit(X_train, y_train_log)

print("正在预测缺失值...")
y_pred_log = model_pipeline.predict(X_predict)
y_pred_final = np.expm1(y_pred_log) # 还原

df.loc[predict_mask, '间接排放'] = y_pred_final
df.to_excel(output_path, index=False)

print(f"预测完成！文件已保存至: {output_path}")