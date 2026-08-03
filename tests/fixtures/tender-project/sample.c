static int tender_hash(int value) {
    return value * 31;
}

static int tender_store(int value) {
    return tender_hash(value) + 1;
}

static int tender_search(int value) {
    return tender_store(value) + tender_hash(value);
}

static int tender_authorize(int value) {
    return value > 0;
}

static int tender_route(int value) {
    return tender_authorize(value) ? tender_search(value) : 0;
}

int tender_project_query(int value) {
    return tender_route(value);
}
