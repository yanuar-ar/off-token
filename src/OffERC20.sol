// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ISSM} from "./ISSM.sol";

contract OffERC20 is ERC20 {
    using SafeERC20 for IERC20;

    address public institution;
    IERC20 immutable public token;
    ISSM immutable public ssm; // settlement security module 

    constructor(address _token, address _ssm) ERC20("offERC20", "offERC20") {
        token = IERC20(_token);
        institution = msg.sender;
        ssm = ISSM(_ssm);
    }

    function collateralize(address to, uint256 amount) public onlyInstitution {
        token.safeTransferFrom(msg.sender, address(this), amount);
        _mint(to, amount);
    }

    function release(address to, uint256 amount, bytes calldata message) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        require(ssm.verify(abi.encode(msg.sender, to, amount), message), "Settlement failed");

        token.safeTransfer(to, amount);
        _burn(msg.sender, amount);
    }


    modifier onlyInstitution() {
        require(msg.sender == institution, "Only institution can call this function");
        _;
    }
}
