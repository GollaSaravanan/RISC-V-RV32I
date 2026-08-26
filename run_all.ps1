Write-Host "  RV32I Core: Running All Testbenches  " -ForegroundColor Cyan
$modules = @(
    @{ Name = "Program Counter"; Files = "rtl/program_counter.v tb/tb_program_counter.v"; Out = "sim_pc.vvp" },
    @{ Name = "Instruction Memory"; Files = "rtl/instruction_memory.v tb/tb_instruction_memory.v"; Out = "sim_im.vvp" },
    @{ Name = "Register File"; Files = "rtl/register_file.v tb/tb_register_file.v"; Out = "sim_rf.vvp" },
    @{ Name = "Instruction Decoder"; Files = "rtl/instruction_decoder.v tb/tb_instruction_decoder.v"; Out = "sim_id.vvp" },
    @{ Name = "ALU"; Files = "rtl/alu.v tb/tb_alu.v"; Out = "sim_alu.vvp" },
    @{ Name = "Data Memory"; Files = "rtl/data_memory.v tb/tb_data_memory.v"; Out = "sim_dm.vvp" },
    @{ Name = "Control Unit"; Files = "rtl/control_unit.v tb/tb_control_unit.v"; Out = "sim_cu.vvp" },
    @{ Name = "Full RV32I Core Integration"; Files = "rtl/program_counter.v rtl/instruction_memory.v rtl/instruction_decoder.v rtl/control_unit.v rtl/register_file.v rtl/alu.v rtl/data_memory.v rtl/riscv_core.v tb/tb_riscv_core.v"; Out = "sim_core.vvp" }
)
foreach ($test in $modules) {
    Write-Host "`n[TEST] Compiling $($test.Name)..." -ForegroundColor Yellow
    $compileCmd = "iverilog -o $($test.Out) $($test.Files)"
    Invoke-Expression $compileCmd
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[PASS] Compilation successful. Running simulation..." -ForegroundColor Green
        vvp $test.Out
        Remove-Item -Force $test.Out -ErrorAction SilentlyContinue
    } else {
        Write-Host "[FAIL] Compilation failed for $($test.Name)!" -ForegroundColor Red
        break
    }
}
Write-Host "  All Testbenches Executed Successfully " -ForegroundColor Cyan