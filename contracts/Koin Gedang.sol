// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// (address) yang diberi izin khusus untuk mencetak (mint) token baru
contract KoinGedang is ERC20, ERC20Pausable, Ownable, ERC20Permit {
    mapping (address => bool) public authorizedMinters;

    // inisiasi nama, simbol, jumlah awal
    constructor()
        ERC20("Koin Gedang", "Gedang")
        Ownable(msg.sender)
        ERC20Permit("Gedang") {
            authorizedMinters[msg.sender] = true; //Own awal bisa mint
            _mint(msg.sender, 1000000 * 10 ** 18);
    }

    // Tambah Minters
    function addMinters (address minters) external onlyOwner{
        authorizedMinters[minters] = true;
    }

    // Remove minters
    function removeMinters (address minters) external onlyOwner{
            authorizedMinters[minters] = false;
    }

    // Mint token baru (cuma Authorized
    function mint (address to, uint256 amount) public {
        require(authorizedMinters[msg.sender], "Cuma Minters resmi yang bole!");
            _mint(to, amount);
    }

    // Burn token dari akun tertentu(butuh allowance)
    function burnFrom (address account, uint256 amount) public{
        _spendAllowance(account, msg.sender, amount); // Allowance atau kode ini dipanggil di ERC20Permit
        _burn(account, amount);
    }

    // burn token
    function burn (uint256 amount) public {
        _burn(msg.sender, amount);
    }

    // Override fungsi transfer buat dukung pause
    function transfer(
        address to,
        uint amount) 
        public override whenNotPaused returns (bool){
        return super.transfer(to, amount);
    }

    // Override transfer from buat dukung paus
    function transferFrom(
        address from,
        address to,
        uint256 amount)
        public whenNotPaused override returns (bool){
        return super.transferFrom(from, to, amount);
    }

    // Override fungsi aprrove buat dukung pausable
    function approve(
        address spender, 
        uint256 amount) 
        public whenNotPaused override returns (bool){
        return super.approve(spender, amount);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable)
    {
        super._update(from, to, value);
    }
}
