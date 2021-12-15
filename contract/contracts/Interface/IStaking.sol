//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
interface IStaking{
    struct staker{
        address   owner;
        uint256   balance;
        uint256   workcount;
    }

    struct policy {
        uint256 policyid;
        uint256 balance;
        uint256 begin;
        uint256 end;
        address[] stakers;
    }
}