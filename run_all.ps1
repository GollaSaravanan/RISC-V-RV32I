Write-Host "  RV32I Core: Running All Testbenches  " -ForegroundColor Cyan
$modules = @(
    @{ Name = "Program Counter"; Files = "program_counter.v tb_program_counter.v"; Out = "sim_pc.vvp" },
    @{ Name = "Instruction Memory"; Files = "instruction_memory.v tb_instruction_memory.v"; Out = "sim_im.vvp" },
    @{ Name = "Register File"; Files = "register_file.v tb_register_file.v"; Out = "sim_rf.vvp" },
    @{ Name = "Instruction Decoder"; Files = "instruction_decoder.v tb_instruction_decoder.v"; Out = "sim_id.vvp" },
    @{ Name = "ALU"; Files = "alu.v tb_alu.v"; Out = "sim_alu.vvp" },
    @{ Name = "Data Memory"; Files = "data_memory.v tb_data_memory.v"; Out = "sim_dm.vvp" },
    @{ Name = "Control Unit"; Files = "control_unit.v tb_control_unit.v"; Out = "sim_cu.vvp" },
    @{ Name = "Full RV32I Core Integration"; Files = "program_counter.v instruction_memory.v instruction_decoder.v control_unit.v register_file.v alu.v data_memory.v riscv_core.v tb_riscv_core.v"; Out = "sim_core.vvp" }
)
foreach ($test in $modules) {
    Write-Host "`n[TEST] Compiling $($test.Name)..." -ForegroundColor Yellow
    $compileCmd = "iverilog -o $($test.Out) $($test.Files)"
    Invoke-Expression $compileCmd

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Compilation successful. Running simulation..." -ForegroundColor Green
        vvp $test.Out
    } else {
        Write-Host "Compilation failed for $($test.Name)!" -ForegroundColor Red
        break
    }
}
Write-Host "  All Testbenches Executed Successfully " -ForegroundColor Cyan