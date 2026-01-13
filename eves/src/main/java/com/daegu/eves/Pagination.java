package com.daegu.eves;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class Pagination {

    private int recordSize = 10;
    private int pageSize = 10;
    private int currentPage = 1;
    private int totalRecord = 0;
    private int totalPage = 0;
    private int startPage = 0;
    private int endPage = 0;
    private int startRecord = 0;
    private boolean prev, next;

    private String keyword;

    public Pagination(int totalRecord, int currentPage) {
        this.totalRecord = totalRecord;
        this.currentPage = currentPage;

        totalPage = (int) Math.ceil((double) totalRecord / recordSize);

        if (totalPage == 0) {
            totalPage = 1;
        }

        if (this.currentPage > totalPage) {
            this.currentPage = totalPage;
        }
        if (this.currentPage < 1) {
            this.currentPage = 1;
        }

        startPage = ((this.currentPage - 1) / pageSize) * pageSize + 1;
        endPage = startPage + pageSize - 1;

        if (endPage > totalPage) {
            endPage = totalPage;
        }

        prev = startPage > 1;
        next = endPage < totalPage;

        startRecord = (this.currentPage - 1) * recordSize;
    }
}