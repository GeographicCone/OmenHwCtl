
// HP Omen Command Center/Gaming Hub
// Common Data

// Note: This is not supposed to be a syntactically-correct .cs file

namespace HP.Omen.Core.Common.PowerControl {

    /* Common */

    // GPU DState List
    public enum GpuDState : byte {
        D1 = 1,
        D2 = 2,
        D3 = 3,
        D4 = 4,
        D5 = 5,
    }

    // IR Overheat Case
    public enum IrOverheatCase {
        IrOverheatThresholdDecreasePl1,
        IrGpsThresholdDecreaseGps,
        IrPl1ThresholdDecreasePl1,
        IrReleaseThresholdIncreasePl1,
        IrReleaseThresholdIncreaseGps,
    }

    // Power Context
    public class PowerContext {
        private const string FeatureName = "PowerControl";
        private const string PlatformSettingsJsonFilePrefix = "HP.Omen.Core.Common.PowerControl.JSON";
        private int _nbPL1UpperBound;
        private static PlatformSettings _settings;
        public Decimal CpuPL1;
        public Decimal CpuPower;
        public GpuDState DState { get; set; }
        public List<int> GpuList;
        public List<int> ThrottlingList30;
        public List<int> ThrottlingList3;
        public bool IsThrottling;
        public bool? PpabEnable { get; set; }
        public bool? TgpEnable { get; set; }
        public const int CpuTempListSize = 3;
        public const int StatusThrottlingNo = 0;
        public const int StatusThrottlingYes = 1;
        public double CpuTemp;
        public double EWMA_CPU_Temp { get; set; }
        public double GpuTemp;
        public double GpuUsage = -1.0;
        public double[3] CpuTempList;
        public int AmbientTemp { get; set; }
        public int BufferCount3s = 3;
        public int Gps { get; set; }
        public int GpuHitRate;
        public int IrSensorThreshold;
        public int IrTemp { get; set; }
        public int NbPL1LowerBound;
        public int Status = 0;
        public int ThrottlingCount30;
        public int ThrottlingCount3;
        public static PlatformSettings Settings { get; set; }
        public static bool IsDesktop { get; private set; }
        public static string PlatformName { get; set; }

        // EWMA - Exponentially-Weighted Moving Average
        public void CalculateEWMA(double lamdaIncrease, double lamdaDecrease) {
             if(this.CpuTemp >= this.EWMA_CPU_Temp)
                  this.EWMA_CPU_Temp = lamdaIncrease * this.CpuTemp + (1.0 - lamdaIncrease) * this.EWMA_CPU_Temp;
             else
                  this.EWMA_CPU_Temp = lamdaDecrease * this.CpuTemp + (1.0 - lamdaDecrease) * this.EWMA_CPU_Temp;
        }

        public void CalculateEWMAIdleMode()
             => this.EWMA_CPU_Temp = 0.10000000149011612 * this.CpuTemp + 0.89999997615814209 * this.EWMA_CPU_Temp;

        public int GetNbPL1UpperBound()
            => this.GpuUsage > 30.0
            && PowerContext.Settings.NbPL1UpperBoundGaming
            <= this._nbPL1UpperBound ?
                PowerContext.Settings.NbPL1UpperBoundGaming : this._nbPL1UpperBound;

        public void ResetEwmaCpuTemp()
            => this.EWMA_CPU_Temp = this.CpuTemp;

        public void SetNbPL1UpperBound(int nbPL1UpperBound)
             => this._nbPL1UpperBound = nbPL1UpperBound;

        this.ThrottlingCount30 = this.ThrottlingCount3 = this.BufferCount3s = 0;

    }

    // Reference Temperature (Used with Desktop)
    public enum ReferenceTemp {
        Unknown = -1, // 0xFFFFFFFF
        Cpu = 0,
        Gpu = 1,
        Ambient = 2,
    }

    // Smart Adapter Status
    public enum SmartAdapterStatus {
        Error = -1, // 0xFFFFFFFF
        NotSupported = 0,
        MeetsRequirement = 1,
        BelowRequirement = 2,
        BatteryPower = 3,
        NotFunctioning = 4,
    }

    // Thermal Policy Version
    public enum ThermalPolicyVersion {
        V0,
        V1,
    }

    /* Fan */

    // Boundary
    public class Boundary {
        public List<int> CPU_Fan_Speed_Lower_Bound_List { get; set; }
        public List<int> CPU_Fan_Speed_Upper_Bound_List { get; set; }
        public List<int> GPU_Fan_Speed_Lower_Bound_List { get; set; }
        public List<int> GPU_Fan_Speed_Upper_Bound_List { get; set; }
        public List<int> IR_Fan_Speed_Lower_Bound_List { get; set; }
        public List<int> IR_Fan_Speed_Upper_Bound_List { get; set; }
    }

    // Fan Table
    public class FanTable {
        public List<int> Fan_Table_CPU_Fan_Speed_List { get; set; }
        public List<int> Fan_Table_CPU_Fan_Speed_List_UI { get; set; }
        public List<int> Fan_Table_CPU_Temperature_List { get; set; }
        public List<int> Fan_Table_GPU_Fan_Speed_List { get; set; }
        public List<int> Fan_Table_GPU_Fan_Speed_List_UI { get; set; }
        public List<int> Fan_Table_GPU_Temperature_List { get; set; }
        public List<int> Fan_Table_IR_Fan_Speed_List { get; set; }   
        public List<int> Fan_Table_IR_Temperature_List { get; set; }
    }

    // Fan Type List
    public enum FanType {
        Unsupported,
        Cpu,
        Gpu,
        Exhaust,
        Pump,
        Intake,
    }

    // Custom Fan Curve
    public class CustomFanCurve {
        public bool IsEanble { get; set; }
        public SwFanControlCustom CustomTable { get; set; }
    }

    // Software Fan Control Custom Data
    public class SwFanControlCustom {
        public FanTable FanTable { get; set; }
        public Boundary Boundary { get; set; }
        public double Lamda_Increase { get; set; }
        public double Lamda_Decrease { get; set; }
    }

    /* Fan: Desktop */

    // Desktop Custom Fan Curve
    public class DtCustomFanCurve : BindableBase {
        private bool _isEanble; // No Typo
        public bool IsEanble { // No Typo
            get => this._isEanble;
            set => this.SetProperty<bool>(ref this._isEanble, value, nameof (IsEanble));
        }
        public DtSwFanControlCustom DtCustomTable { get; set; }
    }

    // Desktop Software Fan Control Custom Data
    public class DtSwFanControlCustom {
        public List<int> FanTable { get; set; }
        public List<int> LowerBound { get; set; }
        public List<int> TemperatureTable { get; set; }
        public List<int> UpperBound { get; set; }
        public double Lamda_Decrease { get; set; }
        public double Lamda_Increase { get; set; }
        }
    }

    // Desktop Fan Data
    public class FanDataDT {
       public DtCustomFanCurve CustomFanCurve { get; set; }
       public FanType FanType { get; set; }
       public ReferenceTemp ReferenceTemp { get; set; }
       public int FanIndex { get; set; }
       public int FanSpeed { get; set; }
    }

    /* Performance Mode */

    // Performance Mode Constants
    public class PerformanceModeConst {
       public const int GamingGpuUsage = 30;
       public const int DefaultIntervalHeartbeat = 30000;
       // [...]
       // Registry key and value names omitted as unimportant
    }

    // Performance Mode List
    public enum PerformanceMode {
        Default =       0, // 0x0000 = 0b0000000000000000
        Performance =   1, // 0x0001 = 0b0000000000000001
        Cool =          2, // 0x0002 = 0b0000000000000010
        Quiet =         3, // 0x0003 = 0b0000000000000011
        Extreme =       4, // 0x0004 = 0b0000000000000100
        L8  =           4, // 0x0004 = 0b0000000000000100
        L0  =          16, // 0x0010 = 0b0000000000010000
        L5  =          17, // 0x0011 = 0b0000000000010001
        L1  =          32, // 0x0020 = 0b0000000000100000
        L6  =          33, // 0x0021 = 0b0000000000100001
        L2  =          48, // 0x0030 = 0b0000000000110000
        L7  =          49, // 0x0031 = 0b0000000000110001 
        L3  =          64, // 0x0040 = 0b0000000001000000
        L4  =          80, // 0x0050 = 0b0000000001010000
        Eco =         256, // 0x0100 = 0b0000000100000000
    }

    // Performance Mode UI
    public enum PerformanceModeOnUI {
        Default,
        Performance,
        Cool,
        Quiet,
        Extreme,
        Balance,
        Eco,
    }

    /* Thermal Control */

    // Thermal Control Mode List
    public enum ThermalControl {
        Max,
        Auto,
        Manual,
    }

    // Thermal Control Mode UI
    public enum ThermalModeOnUI {
        Max_Auto_Manual,
        Auto_Max,
        Auto_Manual,
        Quiet_Normal_Turbo,
    }
}
