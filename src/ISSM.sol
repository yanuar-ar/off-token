// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


interface ISSM {
    function verify(bytes calldata metadata,bytes calldata message) external view returns (bool);
}
