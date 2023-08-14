
// HP Omen Command Center/Gaming Hub
// Platform Data for Ralph ADL N20E
// (HP Omen 16 8A14 22C1 GN20E DDS E3/E6)

// Note: This is not supposed to be a syntactically-correct .cs file

namespace HP.Omen.Core.Common.PowerControl {
    public class PlatformSettings {
        public string Version = "1.0";

        public Decimal Decrease = 0.5;
        public Decimal Increase = 5;
        public Decimal WorkingRatioPL1 = 0.9;
        public GpuConsts GpuSettings { DataCount = 5, UsageCount = 3, UsageGaming = 20, UsageThreshold = 30, UsageVideo = 20 }
        public List<int> IrGpsThreshold { get; set; } = [43, 45, 51, 47, 44, 52, 50, 49];
        public List<int> IrOverheatThreshold { get; set; } = [44, 46, 50, 46, 43, 40, 49, 48];
        public List<int> IrPl1Threshold { get; set; } = [38, 38, 40, 37, 38, 52, 42, 44];
        public List<int> IrReleaseThreshold { get; set; } = [40, 42, 38, 35, 36, 36, 40, 42];
        public List<int> IrSensorThresholdN18E = [48, 48, 49, 48, 45, 49, 49, 49];
        public List<int> IrSensorThresholdN18P = [50, 49, 52, 48, 46, 53, 53, 53];
        public List<int> NbPL1LowerBound = [25, 25, 25, 25, 25, 35, 35, 35]; // For each Performance Mode (L0 - L7)
        public bool PpabOffWhenIrOverheat { get; set; } // Not Defined
        public bool PpabOnInPerformanceMode { get; set; } // Not Defined
        public int AmbientOverheatThreshold { get; set; } = 70; // Default
        public int CpuOverheatThreshold { get; set; } = 90; // Default
        public int DtPL1UpperBound; // Not Defined
        public int GpuOverheatThreshold { get; set; } = 90; // Default
        public int IntervalAlgoLong = 30000;
        public int IntervalAlgoShort = 1000;
        public int IntervalHeartbeat { get; set; } = 30000;
        public int IrCycle { get; set; } = 30; // Default
        public int IrOverheatPl1Reduce { get; set; } = 5; // Default
        public int IrPl1Reduce { get; set; } = 5; // Default
        public int IrSensorThreshold = 55;
        public int IrSensorThresholdDefault = 48;
        public int NbPL1LowerBoundL0 = 23;
        public int NbPL1LowerBoundL1 = 30;
        public int NbPL1LowerBoundMaxP = 25;
        public int NbPL1LowerBoundMaxQ = 25;
        public int NbPL1UpperBound = 55;
        public int NbPL1UpperBoundDefault { get; set; } = 55;
        public int NbPL1UpperBoundGaming { get; set; } = 90; // Default 70
        public int NbPL1UpperBoundPerformance { get; set; } = 90;
        public int NbPL1UpperBoundPerformanceWithOC { get; set; } // Not Defined
        public int PL1DefaultValue { get; set; } // Not Defined
        public int PL1DefaultValueI5 = 55;
        public int PL1DefaultValueI7; // Not Defined
        public int PL1DefaultValueI9; // Not Defined
        public int PL1DeltaValue = 3;
        public int PL4_Threshold { get; set; } = 110;
        public int RecorderLong = 30;
        public int RecorderShort = 3;
        public int TppMaxValue { get; set; } = 60; // Default
        public int temperatureThrottlingBalance { get; set; } = 90; // Default Repeated
        public int temperatureThrottlingPerformance { get; set; } = 95; // Default Repeated

        public SwFanControlCustom SwFanControlCustomDefault { 
            public FanTable FanTable { 
                public List<int> Fan_Table_CPU_Fan_Speed_List = [0, 21, 22, 24, 26, 28, 29, 32, 37, 40];
                public List<int> Fan_Table_CPU_Temperature_List =  [45, 46, 50, 62, 68, 72, 76, 79, 82, 85];
                public List<int> Fan_Table_GPU_Fan_Speed_List = [0, 21, 22, 24, 26, 28, 29, 32, 37, 40];
                public List<int> Fan_Table_GPU_Temperature_List = [41, 42, 44, 53, 58, 60, 63, 70, 73, 76];
                public List<int> Fan_Table_IR_Fan_Speed_List = [0, 21, 22, 24, 26, 28, 29, 32, 37, 40];
                public List<int> Fan_Table_IR_Temperature_List = [34, 35, 36, 37, 39, 41, 43, 45, 48, 51];
                get; set;
            }
            public double Lamda_Decrease { get; set; } = 0.05;
            public double Lamda_Increase { get; set; } = 0.7;
            get; set;
        }

        public SwFanControlCustom SwFanControlCustomPerformance {
            public FanTable FanTable {
                public List<int> Fan_Table_CPU_Fan_Speed_List = [22, 24, 28, 29, 32, 37, 40, 45];
                public List<int> Fan_Table_CPU_Temperature_List = [45, 60, 72, 75, 78, 81, 83, 86];
                public List<int> Fan_Table_GPU_Fan_Speed_List = [22, 24, 28, 29, 32, 37, 40, 45, 50, 55];
                public List<int> Fan_Table_GPU_Temperature_List = [45, 49, 52, 56, 59, 61, 64, 72, 75, 76];
                public List<int> Fan_Table_IR_Fan_Speed_List = [22, 24, 28, 29, 32, 37, 40, 45, 50, 55];
                public List<int> Fan_Table_IR_Temperature_List = [33, 35, 38, 40, 42, 43, 44, 47, 49, 51];
                get; set;
            }
            public double Lamda_Decrease { get; set; } = 0.07;
            public double Lamda_Increase { get; set; } = 0.05;
            get; set;
        }

        public SwFanControlCustom SwFanControlCustomFanCurve {
            public Boundary Boundary {
                public List<int> CPU_Fan_Speed_Lower_Bound_List = [15, 15, 15, 15, 21, 21, 27, 27, 27];
                public List<int> CPU_Fan_Speed_Upper_Bound_List = [55, 55, 55, 55, 55, 55, 55, 55, 55];
                public List<int> GPU_Fan_Speed_Lower_Bound_List = [15, 15, 15, 15, 21, 21, 27, 27, 27];
                public List<int> GPU_Fan_Speed_Upper_Bound_List = [55, 55, 55, 55, 55, 55, 55, 55, 55];
                public List<int> IR_Fan_Speed_Lower_Bound_List = [0];
                public List<int> IR_Fan_Speed_Upper_Bound_List = [55];
                get; set;
            }
            public FanTable FanTable {
                public List<int> Fan_Table_CPU_Fan_Speed_List = [18, 22, 22, 24, 26, 29, 32, 37, 40];
                public List<int> Fan_Table_CPU_Temperature_List = [50, 55, 60, 65, 70, 75, 80, 85, 90];
                public List<int> Fan_Table_GPU_Fan_Speed_List = [0, 0, 0, 0, 0, 0, 0, 40, 40];
                public List<int> Fan_Table_GPU_Temperature_List = [50, 55, 60, 65, 70, 75, 80, 85, 90];
                public List<int> Fan_Table_IR_Fan_Speed_List = [0, 40];
                public List<int> Fan_Table_IR_Temperature_List = [40, 52];
                get; set;
            }
            public double Lamda_Decrease { get; set; } = 0.1;
            public double Lamda_Increase { get; set; } = 0.1;
            get; set;
        }

        // Initally Empty
        public FanTable FanTable { get; set; }
        public double Lamda_Decrease { get; set; }
        public double Lamda_Increase { get; set; }

        // Desktop: Not Defined
        public DtSwFanControlCustom DtSwFanControlCustomFanCurveAcsCPU {
            public List<int> FanTable { get; set; }
            public List<int> LowerBound { get; set; }
            public List<int> TemperatureTable { get; set; }
            public List<int> UpperBound { get; set; }
            public double Lamda_Decrease { get; set; }
            public double Lamda_Increase { get; set; }
            get; set;
        }
        public DtSwFanControlCustom DtSwFanControlCustomFanCurveExhaust {
            public List<int> FanTable { get; set; }
            public List<int> LowerBound { get; set; }
            public List<int> TemperatureTable { get; set; }
            public List<int> UpperBound { get; set; }
            public double Lamda_Decrease { get; set; }
            public double Lamda_Increase { get; set; }
            get; set;
        }
        public DtSwFanControlCustom DtSwFanControlCustomFanCurveIntake {
            public List<int> FanTable { get; set; }
            public List<int> LowerBound { get; set; }
            public List<int> TemperatureTable { get; set; }
            public List<int> UpperBound { get; set; }
            public double Lamda_Decrease { get; set; }
            public double Lamda_Increase { get; set; }
            get; set;
        }
        public DtSwFanControlCustom DtSwFanControlCustomFanCurveLcsCPU {
            public List<int> FanTable { get; set; }
            public List<int> LowerBound { get; set; }
            public List<int> TemperatureTable { get; set; }
            public List<int> UpperBound { get; set; }
            public double Lamda_Decrease { get; set; }
            public double Lamda_Increase { get; set; }
            get; set;
        }
    }
}
